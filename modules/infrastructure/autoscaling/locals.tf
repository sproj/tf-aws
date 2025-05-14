locals {
  autoscaling_permissions = {
    creator = [
      "autoscaling:CreateAutoScalingGroup",
      "autoscaling:DeleteAutoScalingGroup",
    ]
    manager = [
      "autoscaling:UpdateAutoScalingGroup",
    ]
    reader = [
      "autoscaling:Describe*",
    ]
  }
}
