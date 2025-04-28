resource "aws_iam_role" "kubernetes_ec2_creator" {
  name = "k8s-ec2-creator"

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
    Name      = "k8s-ec2-creator"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_policy" "kubernetes_ec2_creator_policy" {
  name = "k8s-ec2-creator-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCreateDeleteResources"
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:CreateInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:CreateNatGateway",
          "ec2:DeleteNatGateway",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:AllocateAddress",
          "ec2:ReleaseAddress",
          "ec2:CreateVpc",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancer",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:DeleteAutoScalingGroup",
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

data "aws_iam_policy_document" "kubernetes_ec2_creator_networking_access" {
  statement {
    actions   = var.networking_allowed_actions
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kubernetes_ec2_creator_networking_policy" {
  name        = "kubernetes-ec2-creator-networking-policy"
  description = "Policy allowing kubernetes-ec2-creator to create networking resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_creator_networking_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}



resource "aws_iam_role_policy_attachment" "creator_attach" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_policy.arn
}

resource "aws_iam_role_policy_attachment" "creator_backend_access" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = var.backend_full_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "creator_networking_access" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_networking_policy.arn
}



data "aws_caller_identity" "current" {}
