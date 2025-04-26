output "available_deployment_types" {
  description = "List of supported deployment types."
  value = [
    "kubernetes-ec2",
    "fargate",
    "eks",
    "ec2-app"
  ]
}
