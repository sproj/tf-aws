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

resource "kubernetes_namespace" "redis_namespace" {
  metadata {
    name = "redis"
  }
}

resource "kubernetes_manifest" "redis_external_secrets" {
  depends_on = [kubernetes_namespace.databases_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/redis-external-secrets.yaml"))
}

resource "kubernetes_manifest" "redis_service" {
  depends_on = [kubernetes_namespace.databases_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/redis-service.yaml"))
}

resource "kubernetes_manifest" "redis_deployment" {
  depends_on = [kubernetes_namespace.redis_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/redis-deployment.yaml"))
}
