# Apply cert-manager secrets and cluster issuer
resource "kubernetes_manifest" "cert_manager_external_secrets" {
  depends_on = [kubernetes_manifest.cluster_secret_store]
  manifest   = yamldecode(file("./cert-manager/cert-manager-external-secrets.yaml"))
}

resource "kubernetes_manifest" "cert_manager_cluster_issuer" {
  depends_on = [kubernetes_manifest.cert_manager_external_secrets]
  manifest   = yamldecode(file("./cert-manager/cluster-issuer.yaml"))
}
