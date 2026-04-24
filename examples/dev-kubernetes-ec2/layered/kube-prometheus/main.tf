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
  region  = var.aws_region
  profile = "kubernetes-ec2-creator"
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "examples/kubernetes-ec2/layered/terraform.tfstate"
    region  = "eu-west-1"
    profile = "kubernetes-ec2-creator"
  }
}

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
  k8s_host = "https://${data.terraform_remote_state.infra.outputs.master_public_ip}:6443"
}

provider "helm" {
  kubernetes {
    host                   = local.k8s_host
    cluster_ca_certificate = base64decode(data.aws_ssm_parameter.cluster_ca_certificate.value)
    client_certificate     = base64decode(data.aws_ssm_parameter.client_certificate.value)
    client_key             = base64decode(data.aws_ssm_parameter.client_key.value)
  }
}

provider "kubernetes" {
  host                   = local.k8s_host
  cluster_ca_certificate = base64decode(data.aws_ssm_parameter.cluster_ca_certificate.value)
  client_certificate     = base64decode(data.aws_ssm_parameter.client_certificate.value)
  client_key             = base64decode(data.aws_ssm_parameter.client_key.value)
}
