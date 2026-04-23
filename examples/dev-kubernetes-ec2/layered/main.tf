terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
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
  depends_on       = [module.base_infrastructure]
  source           = "./control_plane"
  instance_type    = var.control_plane_instance_type
  ami_id           = var.ami_id
  root_volume_size = var.control_plane_root_volume_size
  name_prefix      = var.name_prefix
}

module "worker_nodes" {
  source               = "./worker_nodes"
  depends_on           = [module.control_plane]
  name_prefix          = var.name_prefix
  instance_type        = var.worker_instance_type
  allowed_ssh_cidr     = var.allowed_ssh_cidr
  ami_id               = var.ami_id
  root_volume_size     = var.worker_root_volume_size
  asg_desired_capacity = 1
  asg_max_capacity     = 3
}

module "cluster_operators" {
  source      = "./cluster_operators"
  depends_on  = [module.worker_nodes]
  env         = var.env
  name_prefix = var.name_prefix
}

module "cluster_workload" {
  source      = "./cluster_workload"
  depends_on  = [module.cluster_operators]
  env         = var.env
  name_prefix = var.name_prefix
}

module "cluster_databases" {
  source      = "./cluster_databases"
  depends_on  = [module.cluster_workload]
  env         = var.env
  name_prefix = var.name_prefix
}

module "cluster_observability" {
  source      = "./cluster_observability"
  depends_on  = [module.cluster_workload]
  env         = var.env
  name_prefix = var.name_prefix
}

