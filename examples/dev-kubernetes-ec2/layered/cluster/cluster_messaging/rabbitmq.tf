terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

resource "kubernetes_namespace" "rabbitmq_namespace" {
  metadata {
    name = "rabbitmq"
  }
}

resource "kubernetes_manifest" "rabbitmq_external_secrets" {
  depends_on = [kubernetes_namespace.rabbitmq_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/rabbitmq/rabbitmq-external-secrets.yaml"))
}

resource "kubernetes_manifest" "rabbitmq_service" {
  depends_on = [kubernetes_namespace.rabbitmq_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/rabbitmq/rabbitmq-service.yaml"))
}

resource "kubernetes_manifest" "rabbitmq_config" {
  depends_on = [kubernetes_namespace.rabbitmq_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/rabbitmq/rabbitmq-config.yaml"))
}

resource "kubernetes_manifest" "rabbitmq_deployment" {
  depends_on = [kubernetes_namespace.rabbitmq_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/rabbitmq/rabbitmq-deployment.yaml"))
}
