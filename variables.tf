variable "aws_region" {
  type        = string
  description = "AWS region where infrastructure will be deployed"
  default     = "us-east-1"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming all resources"
  default     = "cmtr-ghjc0xhd"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.10.0.0/16"
}

variable "public_subnets" {
  type        = map(string)
  description = "Map of availability zone keys to public subnet CIDR blocks"
  default = {
    a = "10.10.1.0/24"
    b = "10.10.3.0/24"
    c = "10.10.5.0/24"
  }
}

variable "allowed_ip_range" {
  type        = list(string)
  description = "List of CIDR ranges allowed for SSH and HTTP access"
}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2 instances"
  default     = "t3.micro"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in the Auto Scaling Group"
  default     = 2
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances in the Auto Scaling Group"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in the Auto Scaling Group"
  default     = 2
}
