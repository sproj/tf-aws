# Install AWS Load Balancer Controller
resource "kubernetes_manifest" "aws_lbc_external_secrets" {
  depends_on = [kubernetes_manifest.cluster_secret_store]
  manifest   = yamldecode(file("${path.module}/aws-lbc/aws-lbc-external-secrets.yaml"))
}

resource "helm_release" "aws_lbc_chart" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  depends_on = [kubernetes_manifest.aws_lbc_external_secrets]
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  values = [templatefile("${path.module}/aws-lbc/aws-lbc-values.yaml", {
    vpcId : var.vpc_id,
    region : var.aws_region
  })]
}
