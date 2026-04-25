resource "helm_release" "kube_prometheus_chart" {
  depends_on       = []
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  values           = [file("${path.module}/values/kube-prometheus-values.yaml")]
  timeout          = 600
}
