variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "name_prefix" {
  type    = string
  default = "cmtr-ghjc0xhd"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "public_subnets" {
  type = map(string)
  # keys expected: a, b, c
  default = {
    a = "10.10.1.0/24"
    b = "10.10.3.0/24"
    c = "10.10.5.0/24"
  }
}

variable "allowed_ip_range" {
  type = list(string)
  description = "List of CIDR ranges allowed for SSH/HTTP access"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 2
}
