variable "name_prefix" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "allowed_ip_range" {
  type = list(string)
}
