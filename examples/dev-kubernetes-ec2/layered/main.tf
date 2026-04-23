terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "kubernetes-ec2-creator"
}

module "base_infrastructure" {
  source           = "./base_infrastructure"
  allowed_ssh_cidr = var.allowed_ssh_cidr
  env              = var.env
  name_prefix      = var.name_prefix
}

module "control_plane" {
  source                = "./control_plane"
  depends_on            = [module.base_infrastructure]
  name_prefix           = var.name_prefix
  instance_type         = var.control_plane_instance_type
  ami_id                = var.ami_id
  root_volume_size      = var.control_plane_root_volume_size
  public_subnet_ids     = module.base_infrastructure.public_subnet_ids
  security_group_ids    = [module.base_infrastructure.master_security_group_id]
  instance_profile_name = module.base_infrastructure.instance_profile_name
}

module "worker_nodes" {
  source                = "./worker_nodes"
  depends_on            = [module.control_plane]
  name_prefix           = var.name_prefix
  instance_type         = var.worker_instance_type
  allowed_ssh_cidr      = var.allowed_ssh_cidr
  ami_id                = var.ami_id
  root_volume_size      = var.worker_root_volume_size
  asg_desired_capacity  = var.asg_desired_capacity
  asg_max_capacity      = var.asg_max_capacity
  public_subnet_ids     = module.base_infrastructure.public_subnet_ids
  security_group_ids    = [module.base_infrastructure.master_security_group_id]
  instance_profile_name = module.base_infrastructure.instance_profile_name
}
