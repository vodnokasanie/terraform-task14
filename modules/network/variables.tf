variable "name_prefix" {
  type        = string
  description = "Prefix for naming network resources"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnets" {
  type        = map(string)
  description = "Map of availability zone keys to public subnet CIDR blocks"
}



data "aws_availability_zones" "available" {}

