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

  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "examples/kubernetes-ec2/cluster_workload/terraform.tfstate"
    region         = "eu-west-1"
    profile        = "kubernetes-ec2-creator"
    dynamodb_table = "tfaws-dev-lock-backend"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "kubernetes-ec2-creator"
}

# Read the public and private IPs written by the control_plane layer
data "terraform_remote_state" "control_plane" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "examples/kubernetes-ec2/control_plane/terraform.tfstate"
    region  = "eu-west-1"
    profile = "kubernetes-ec2-creator"
  }
}

# Read the VPC id written by the base_infrastructure layer
data "terraform_remote_state" "base_infrastructure" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "examples/kubernetes-ec2/base_infrastructure/terraform.tfstate"
    region  = "eu-west-1"
    profile = "kubernetes-ec2-creator"
  }
}

# Read the TLS credentials written to SSM by master-runtime.sh at cluster init
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

# Avoid repeating these across both provider blocks
locals {
  k8s_host            = "https://${data.terraform_remote_state.control_plane.outputs.master_public_ip}:6443"
  k8s_tls_server_name = data.terraform_remote_state.control_plane.outputs.master_private_ip
}

provider "helm" {
  kubernetes {
    host                   = local.k8s_host
    tls_server_name        = local.k8s_tls_server_name
    cluster_ca_certificate = base64decode(data.aws_ssm_parameter.cluster_ca_certificate.value)
    client_certificate     = base64decode(data.aws_ssm_parameter.client_certificate.value)
    client_key             = base64decode(data.aws_ssm_parameter.client_key.value)
  }
}

provider "kubernetes" {
  host                   = local.k8s_host
  tls_server_name        = local.k8s_tls_server_name
  cluster_ca_certificate = base64decode(data.aws_ssm_parameter.cluster_ca_certificate.value)
  client_certificate     = base64decode(data.aws_ssm_parameter.client_certificate.value)
  client_key             = base64decode(data.aws_ssm_parameter.client_key.value)
}

