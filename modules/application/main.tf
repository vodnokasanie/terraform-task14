data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Launch Template user_data: generate page with instance metadata (instance-id and product_uuid)
locals {
  user_data = <<-EOF
              #!/bin/bash
              # get compute machine uuid
              COMPUTE_MACHINE_UUID=$(cat /sys/devices/virtual/dmi/id/product_uuid | tr '[:upper:]' '[:lower:]' || echo "unknown-uuid")
              # get instance id from metadata (AWS)
              COMPUTE_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || echo "unknown-instance")
              cat > /var/www/html/index.html <<HTML
              <html>
                <head><title>Instance Info</title></head>
                <body>
                  <h1>Instance Info</h1>
                  <p>This message was generated on instance $${COMPUTE_INSTANCE_ID} with the following UUID $${COMPUTE_MACHINE_UUID}</p>
                </body>
              </html>
              HTML
              # ensure web server directory exists
              mkdir -p /var/www/html
              # move index into place (already written)
              # start a simple python HTTP server on port 80 in background
              nohup bash -c "cd /var/www/html && python3 -m http.server 80" >/var/log/simple_http.log 2>&1 &
              EOF
}

resource "aws_launch_template" "lt" {
  name_prefix   = "${var.name_prefix}-template-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  user_data = base64encode(local.user_data)

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    # security groups referenced by id
    security_groups = [var.ssh_sg_id, var.private_http_sg_id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.name_prefix}-instance" }
  }
}

# ALB
resource "aws_lb" "alb" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.public_http_sg_id]
  subnets            = var.subnet_ids

  tags = {
    Name = "${var.name_prefix}-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.from_subnet.id

  health_check {
    path     = "/"
    port     = "80"
    protocol = "HTTP"
  }
}

# Because we do not create a full VPC resource inside this module, we need a VPC id.
# Simpler: look up VPC by the first subnet id's vpc_id using a data source:
data "aws_subnet" "first" {
  id = var.subnet_ids[0]
}

data "aws_vpc" "from_subnet" {
  id = data.aws_subnet.first.vpc_id
}

# Use that VPC for target group:
resource "aws_lb_target_group" "app_tg_correct" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.from_subnet.id

  health_check {
    path     = "/"
    port     = "80"
    protocol = "HTTP"
  }

  tags = { Name = "${var.name_prefix}-tg" }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg_correct.arn
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  name                = "${var.name_prefix}-asg"
  max_size            = var.max_size
  min_size            = var.min_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids
  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.app_tg_correct.arn]

  lifecycle {
    ignore_changes = [
      # requested: ignore changes to load_balancers and target_group_arns
      target_group_arns,
      load_balancers,
    ]
  }

  tags = [
    {
      key                 = "Name"
      value               = "${var.name_prefix}-asg-instance"
      propagate_at_launch = true
    }
  ]
}

# Optionally attach using aws_autoscaling_attachment — note: attaching via ASG target_group_arns is the current recommended way for ALB.
# The "aws_autoscaling_attachment" resource is typically used for classic ELB. Keep it commented or remove if not needed.
# resource "aws_autoscaling_attachment" "asg_attach" {
#   autoscaling_group_name = aws_autoscaling_group.app_asg.name
#   lb_target_group_arn    = aws_lb_target_group.app_tg_correct.arn
# }

