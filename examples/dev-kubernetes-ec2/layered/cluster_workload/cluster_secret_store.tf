# install cluster secret store enabled by ESO from previous step
resource "kubernetes_manifest" "cluster_secret_store" {
  manifest   = yamldecode(file("./eso/cluster-secret-store.yaml"))
}