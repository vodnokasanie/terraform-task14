variable "name_prefix" {}
variable "vpc_id" {}
variable "allowed_ip_range" {
  type = list(string)
}

# SSH Security Group
resource "aws_security_group" "ssh" {
  name        = "${var.name_prefix}-ssh-sg"
  description = "Allow SSH"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-ssh-sg" }
}

resource "aws_security_group_rule" "ssh_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.ssh.id
  cidr_blocks       = var.allowed_ip_range
  description       = "Allow SSH from allowed ranges"
}

# Public HTTP Security Group
resource "aws_security_group" "public_http" {
  name        = "${var.name_prefix}-public-http-sg"
  description = "Allow HTTP from allowed IP ranges"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-public-http-sg" }
}

resource "aws_security_group_rule" "public_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.public_http.id
  cidr_blocks       = var.allowed_ip_range
  description       = "Allow HTTP from allowed ranges"
}

# Private HTTP Security Group (allow HTTP only from public_http SG)
resource "aws_security_group" "private_http" {
  name        = "${var.name_prefix}-private-http-sg"
  description = "Allow HTTP only from public http security group"
  vpc_id      = var.vpc_id

  tags = { Name = "${var.name_prefix}-private-http-sg" }
}

resource "aws_security_group_rule" "private_http_from_public_sg" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_http.id
  source_security_group_id = aws_security_group.public_http.id
  description              = "Allow HTTP from public-http-sg"
}
