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

resource "kubernetes_namespace" "databases_namespace" {
  metadata {
    name = "databases"
  }
}

resource "kubernetes_manifest" "postgres_external_secrets" {
  depends_on = [kubernetes_namespace.databases_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/postgres-external-secrets.yaml"))
}

resource "kubernetes_manifest" "postgres_stateful_set" {
  depends_on = [kubernetes_namespace.databases_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/postgres-statefulset.yaml"))
}

resource "kubernetes_manifest" "postgres_headless_service" {
  depends_on = [kubernetes_namespace.databases_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/headless-service.yaml"))
}

resource "kubernetes_manifest" "postgres_service" {
  depends_on = [kubernetes_namespace.databases_namespace]
  manifest   = yamldecode(file("${path.module}/manifests/postgres-service.yaml"))
}
