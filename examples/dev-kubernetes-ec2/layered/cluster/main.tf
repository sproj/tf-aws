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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "kubernetes-ec2-creator"
}

# Read the infra root module state for the k8s API endpoint
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "examples/kubernetes-ec2/layered/terraform.tfstate"
    region  = "eu-west-1"
    profile = "kubernetes-ec2-creator"
  }
}

# Read k8s TLS credentials written to SSM by kubeadm on the control plane node
data "aws_ssm_parameter" "cluster_ca_certificate" {
  name            = "/${var.env}/${var.name_prefix}/k8s-api/cluster_ca_certificate"
  with_decryption = true
}

data "aws_ssm_parameter" "client_certificate" {
  name            = "/${var.env}/${var.name_prefix}/k8s-api/client_certificate"
  with_decryption = true
}

data "aws_ssm_parameter" "client_key" {
  name            = "/${var.env}/${var.name_prefix}/k8s-api/client_key"
  with_decryption = true
}

locals {
  k8s_host            = "https://${data.terraform_remote_state.infra.outputs.master_public_ip}:6443"
  k8s_tls_server_name = data.terraform_remote_state.infra.outputs.master_private_ip
}

provider "helm" {
  kubernetes {
    host                   = local.k8s_host
    # tls_server_name        = local.k8s_tls_server_name
    cluster_ca_certificate = base64decode(data.aws_ssm_parameter.cluster_ca_certificate.value)
    client_certificate     = base64decode(data.aws_ssm_parameter.client_certificate.value)
    client_key             = base64decode(data.aws_ssm_parameter.client_key.value)
  }
}

provider "kubernetes" {
  host                   = local.k8s_host
  # tls_server_name        = local.k8s_tls_server_name
  cluster_ca_certificate = base64decode(data.aws_ssm_parameter.cluster_ca_certificate.value)
  client_certificate     = base64decode(data.aws_ssm_parameter.client_certificate.value)
  client_key             = base64decode(data.aws_ssm_parameter.client_key.value)
}

module "cluster_operators" {
  source      = "./cluster_operators"
  env         = var.env
  name_prefix = var.name_prefix
}

module "cluster_workload" {
  source      = "./cluster_workload"
  depends_on  = [module.cluster_operators]
  env         = var.env
  name_prefix = var.name_prefix
  aws_region  = var.aws_region
  vpc_id      = data.terraform_remote_state.infra.outputs.vpc_id
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
