terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }

  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "examples/kubernetes-ec2/dns_records/terraform.tfstate"
    region         = "eu-west-1"
    profile        = "kubernetes-ec2-creator"
    dynamodb_table = "tfaws-dev-lock-backend"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "kubernetes-ec2-creator"
}

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "bootstrap/dns/terraform.tfstate"
    region  = "eu-west-1"
    profile = "super-user"
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

# Avoid repeating these across both provider blocks
locals {
  k8s_host            = "https://${data.terraform_remote_state.control_plane.outputs.master_public_ip}:6443"
  k8s_tls_server_name = data.terraform_remote_state.control_plane.outputs.master_private_ip
}

provider "kubernetes" {
  host                   = local.k8s_host
  tls_server_name        = local.k8s_tls_server_name
  cluster_ca_certificate = base64decode(data.aws_ssm_parameter.cluster_ca_certificate.value)
  client_certificate     = base64decode(data.aws_ssm_parameter.client_certificate.value)
  client_key             = base64decode(data.aws_ssm_parameter.client_key.value)
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

resource "aws_route53_record" "route_52_alias_record" {
  type    = "A"
  name    = var.the_domain_name
  zone_id = data.terraform_remote_state.dns.outputs.zone_id
  alias {
    name                   = data.kubernetes_service.ingress_nginx.status[0].load_balancer[0].ingress[0].hostname
    evaluate_target_health = true
    zone_id                = var.nlb_zone_id
  }
}
