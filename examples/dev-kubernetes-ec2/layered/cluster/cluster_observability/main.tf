terraform {
  required_version = ">= 1.3"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

resource "kubernetes_namespace_v1" "observability_namespace" {
  metadata {
    name = "observability"
  }
}

resource "kubernetes_manifest" "jaeger_deployment" {
  depends_on = [kubernetes_namespace_v1.observability_namespace]
  manifest   = yamldecode(file("${path.module}/jaeger/jaeger-deployment.yaml"))
}

resource "kubernetes_manifest" "jaeger_service" {
  depends_on = [kubernetes_namespace_v1.observability_namespace]
  manifest   = yamldecode(file("${path.module}/jaeger/jaeger-service.yaml"))
}
