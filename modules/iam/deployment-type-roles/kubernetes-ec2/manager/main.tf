resource "aws_iam_role" "kubernetes_ec2_manager" {
  name = "k8s-ec2-manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.bootstrapper_role_name}"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name      = "k8s-ec2-manager"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_policy" "kubernetes_ec2_manager_policy" {
  name = "k8s-ec2-manager-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowModifyResources"
        Effect = "Allow"
        Action = [
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyVolume",
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "autoscaling:UpdateAutoScalingGroup",
          "iam:PassRole"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_role_policy_attachment" "manager_attach" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = aws_iam_policy.kubernetes_ec2_manager_policy.arn
}

data "aws_caller_identity" "current" {}
