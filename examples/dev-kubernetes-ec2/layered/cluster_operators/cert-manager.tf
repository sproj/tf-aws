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
