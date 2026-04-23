terraform {
  required_version = ">= 1.3"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

resource "kubernetes_manifest" "jaeger_deployment" {
  manifest = yamldecode(file("${path.module}/jaeger/jaeger-deployment.yaml"))
}

resource "kubernetes_manifest" "jaeger_service" {
  manifest = yamldecode(file("${path.module}/jaeger/jaeger-service.yaml"))
}
