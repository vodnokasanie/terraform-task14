variable "name_prefix" {
  type        = string
  description = "Prefix for naming application resources"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the application resources"
}

variable "ssh_sg_id" {
  type        = string
  description = "Security group ID allowing SSH access"
}

variable "public_http_sg_id" {
  type        = string
  description = "Security group ID allowing public HTTP access"
}

variable "private_http_sg_id" {
  type        = string
  description = "Security group ID allowing private HTTP access from the public SG"
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instances in the launch template"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in the Auto Scaling Group"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances in the Auto Scaling Group"
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in the Auto Scaling Group"
}
