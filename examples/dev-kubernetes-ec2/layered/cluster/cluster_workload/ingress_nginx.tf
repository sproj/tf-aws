# install ingress-nginx
resource "kubernetes_namespace" "ingress_nginx_namespace" {
  metadata {
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress_nginx_chart" {
  depends_on = [kubernetes_namespace.ingress_nginx_namespace, helm_release.aws_lbc_chart]
  namespace  = "ingress-nginx"
  name       = "ingress-nginx"
  chart      = "https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-4.15.1/ingress-nginx-4.15.1.tgz"
  values     = [file("${path.module}/ingress-nginx/ingress-nginx-values.yaml")]
  wait       = false
  timeout    = 600
}
