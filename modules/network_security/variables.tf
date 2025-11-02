variable "name_prefix" {
  type        = string
  description = "Prefix for naming security group resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where the security groups will be created"
}

variable "allowed_ip_range" {
  type        = list(string)
  description = "List of CIDR ranges allowed for ingress rules"
}
