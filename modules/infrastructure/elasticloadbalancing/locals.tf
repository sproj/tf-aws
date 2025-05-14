locals {
  elasticloadbalancing_permissions = {
    creator = [
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancer",
    ]
    manager = [
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:ModifyListener",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
    ]
    reader = [
      "elasticloadbalancing:Describe*",
    ]
  }
}
