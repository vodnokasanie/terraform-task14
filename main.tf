

provider "aws" {
  region = var.aws_region
}

module "network" {
  source      = "./modules/network"
  name_prefix = var.name_prefix

  vpc_cidr       = var.vpc_cidr
  public_subnets = var.public_subnets
}

module "network_security" {
  source           = "./modules/network_security"
  name_prefix      = var.name_prefix
  vpc_id           = module.network.vpc_id
  allowed_ip_range = var.allowed_ip_range
}

module "app" {
  source      = "./modules/application"
  name_prefix = var.name_prefix

  subnet_ids         = module.network.public_subnet_ids
  ssh_sg_id          = module.network_security.ssh_sg_id
  public_http_sg_id  = module.network_security.public_http_sg_id
  private_http_sg_id = module.network_security.private_http_sg_id

  instance_type    = var.instance_type
  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size
}
