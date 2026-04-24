resource "helm_release" "kube_prometheus_chart" {
  depends_on = []
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "observability"
  values     = [file("${path.module}/values/kube-prometheus-values.yaml")]
  timeout    = 600
}
