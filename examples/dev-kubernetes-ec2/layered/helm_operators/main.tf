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
    key            = "examples/kubernetes-ec2/helm_operators/terraform.tfstate"
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

# Install ESO
resource "kubernetes_namespace" "external_secrets_namespace" {
  metadata {
    name = "external-secrets"
  }
}

data "aws_ssm_parameter" "eso_reader_ssm_access_key_id" {
  name            = "/${var.env}/${var.name_prefix}/eso-reader-ssm-access-key-id"
  with_decryption = true
}

data "aws_ssm_parameter" "eso_reader_ssm_secret_access_key" {
  name            = "/${var.env}/${var.name_prefix}/eso-reader-ssm-secret-access-key"
  with_decryption = true
}

resource "kubernetes_secret" "eso_reader_aws_credentials" {
  data = {
    "access-key-id" : data.aws_ssm_parameter.eso_reader_ssm_access_key_id.value
    "secret-access-key" : data.aws_ssm_parameter.eso_reader_ssm_secret_access_key.value
  }

  metadata {
    namespace = "external-secrets"
    name      = "eso-reader-aws-credentials"
  }
}

resource "helm_release" "external_secrets" {
  namespace  = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  name       = "external-secrets"
  depends_on = [kubernetes_namespace.external_secrets_namespace, kubernetes_secret.eso_reader_aws_credentials]
}

resource "kubernetes_manifest" "cluster_secret_store" {
  depends_on = [helm_release.external_secrets]
  manifest   = yamldecode(file("./eso/cluster-secret-store.yaml"))
}

# Install EBS CSI driver
data "aws_ssm_parameter" "ebs_csi_ec2_access_key_id" {
  name            = "/${var.env}/${var.name_prefix}/ebs-csi-ec2-access-key-id"
  with_decryption = true
}

data "aws_ssm_parameter" "ebs_csi_ec2_secret_access_key" {
  name            = "/${var.env}/${var.name_prefix}/ebs-csi-ec2-secret-access-key"
  with_decryption = true
}

resource "kubernetes_secret" "ebs_csi_driver_credentials" {
  data = {
    "key_id" : data.aws_ssm_parameter.ebs_csi_ec2_access_key_id.value,
    "access_key" : data.aws_ssm_parameter.ebs_csi_ec2_secret_access_key.value
  }

  metadata {
    namespace = "kube-system"
    name      = "aws-secret"
  }
}

resource "helm_release" "ebs_csi_driver" {
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  name       = "aws-ebs-csi-driver"
  depends_on = [kubernetes_secret.ebs_csi_driver_credentials]
  values     = [file("./ebs-csi/ebs-csi-values.yaml")]
}

resource "kubernetes_storage_class_v1" "ebs_csi_storageclass" {
  depends_on = [helm_release.ebs_csi_driver]
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    "type" : "gp3"
  }
}

# Apply block-imds
resource "kubernetes_manifest" "block_imds" {
  depends_on = [kubernetes_storage_class_v1.ebs_csi_storageclass]
  manifest   = yamldecode(file("./block-imds/block-imds.yaml"))
}

# Install cert-manager
resource "kubernetes_namespace" "cert_manager_namespace" {
  metadata {
    name = "cert-manager"
  }
}

resource "helm_release" "cert_manager_chart" {
  depends_on = [kubernetes_namespace.cert_manager_namespace]
  namespace  = "cert-manager"
  name       = "cert-manager"
  chart      = "https://charts.jetstack.io/charts/cert-manager-v1.16.2.tgz"
  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "kubernetes_manifest" "cert_manager_external_secrets" {
  depends_on = [helm_release.cert_manager_chart, kubernetes_manifest.cluster_secret_store]
  manifest   = yamldecode(file("./cert-manager/cert-manager-external-secrets.yaml"))
}

resource "kubernetes_manifest" "cert_manager_cluster_issuer" {
  depends_on = [helm_release.cert_manager_chart, kubernetes_manifest.cert_manager_external_secrets]
  manifest   = yamldecode(file("./cert-manager/cluster-issuer.yaml"))
}

# Install AWS Load Balancer Controller
resource "kubernetes_manifest" "aws_lbc_external_secrets" {
  depends_on = [kubernetes_manifest.cluster_secret_store]
  manifest   = yamldecode(file("./aws-lbc/aws-lbc-external-secrets.yaml"))
}

resource "helm_release" "aws_lbc_chart" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [kubernetes_manifest.aws_lbc_external_secrets]
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  values     = [file("./aws-lbc/aws-lbc-values.yaml")]
}

# install ingress-nginx
resource "kubernetes_namespace" "ingress_nginx_namespace" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx_chart" {
  depends_on = [kubernetes_namespace.ingress_nginx_namespace, helm_release.aws_lbc_chart]
  namespace  = "ingress-nginx"
  name       = "ingress-nginx"
  chart      = "https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.15.1/ingress-nginx-4.15.1.tgz"
  values     = [file("./ingress-nginx/ingress-nginx-values.yaml")]
  wait       = false
  timeout    = 600
}
