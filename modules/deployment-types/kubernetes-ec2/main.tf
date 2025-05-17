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

module "networking" {
  source                    = "./networking"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  availability_zones        = var.availability_zones
  name_prefix               = var.name_prefix
  tags                      = var.tags
}

module "security_groups" {
  source           = "./security-groups"
  vpc_id           = module.networking.vpc_id
  vpc_cidr_block   = var.vpc_cidr_block
  allowed_ssh_cidr = var.allowed_ssh_cidr
  name_prefix      = var.name_prefix
  tags             = var.tags
}

module "iam_instance_profile" {
  source      = "./iam-instance-profile"
  name_prefix = var.name_prefix
  tags        = var.tags
}

module "ec2_nodes" {
  source               = "./ec2-nodes"
  subnet_ids           = module.networking.public_subnet_ids
  security_group_ids   = module.security_groups.node_sg_ids
  iam_instance_profile = module.iam_instance_profile.profile_name
  ami_id               = var.node_ami_id
  instance_type        = var.node_instance_type
  desired_capacity     = var.node_desired_capacity
  min_size             = var.node_min_size
  max_size             = var.node_max_size
  name_prefix          = var.name_prefix
  tags                 = var.tags
}

module "ec2_master" {
  source               = "./ec2-master"
  subnet_id            = module.networking.public_subnet_ids[0]
  security_group_ids   = module.security_groups.master_sg_ids
  iam_instance_profile = module.iam_instance_profile.profile_name
  ami_id               = var.master_ami_id
  instance_type        = var.master_instance_type
  key_name             = var.key_name
  name_prefix          = var.name_prefix
  tags                 = var.tags
}
# Optionally, add ECR and Load Balancer modules as needed
