terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "base_infrastructure" {
  source = "./base_infrastructure"
  # everything
  name_prefix = var.name_prefix
  tags        = var.tags
  # networking
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  availability_zones        = var.availability_zones
  # security groups
  allowed_ssh_cidr = var.allowed_ssh_cidr
}

module "control_plane" {
  source                    = "./control_plane"
  public_subnet_ids         = module.base_infrastructure.public_subnet_ids
  security_group_ids        = module.base_infrastructure.master_security_group_ids
  iam_instance_profile_name = module.base_infrastructure.instance_profile_name
  ami_id                    = var.node_ami_id
  instance_type             = var.node_instance_type
  desired_capacity          = var.node_desired_capacity
  min_size                  = var.node_min_size
  max_size                  = var.node_max_size
  key_name                  = var.key_name
  name_prefix               = var.name_prefix
  tags                      = var.tags
}

module "worker_nodes" {
  source                    = "./worker_nodes"
  public_subnet_ids         = module.base_infrastructure.public_subnet_ids
  security_group_ids        = module.base_infrastructure.node_security_group_ids
  iam_instance_profile_name = module.base_infrastructure.instance_profile_name
  ami_id                    = var.node_ami_id
  instance_type             = var.node_instance_type
  desired_capacity          = var.node_desired_capacity
  min_size                  = var.node_min_size
  max_size                  = var.node_max_size
  name_prefix               = var.name_prefix
  tags                      = var.tags
}

# Optionally, add ECR and Load Balancer modules as needed
