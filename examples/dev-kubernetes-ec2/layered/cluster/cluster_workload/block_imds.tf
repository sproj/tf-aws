# Apply block-imds
resource "kubernetes_manifest" "block_imds" {
  depends_on = [kubernetes_storage_class_v1.ebs_csi_storageclass]
  manifest   = yamldecode(file("${path.module}/block-imds/block-imds.yaml"))
}