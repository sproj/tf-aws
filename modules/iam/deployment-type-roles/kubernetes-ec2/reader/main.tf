resource "aws_iam_role" "kubernetes_ec2_reader" {
  name = "k8s-ec2-reader"

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
    Name      = "k8s-ec2-reader"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_policy" "kubernetes_ec2_reader_policy" {
  name = "k8s-ec2-reader-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowReadOnly"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "elasticloadbalancing:Describe*",
          "autoscaling:Describe*",
          "iam:Get*",
          "iam:List*",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = ["*"]
      }
    ]
  })

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

data "aws_iam_policy_document" "kubernetes_ec2_reader_networking_access" {
  statement {
    sid       = "AllowNetworkingDescriptionActions"
    effect    = "Allow"
    actions   = var.networking_allowed_actions
    resources = ["*"]
  }
}

resource "aws_iam_policy" "kubernetes_ec2_reader_networking_policy" {
  name        = "kubernetes-ec2-reader-networking-policy"
  description = "Policy allowing kubernetes-ec2-reader to read networking resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_reader_networking_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_role_policy_attachment" "reader_attach" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_policy.arn
}

resource "aws_iam_role_policy_attachment" "reader_backend_access" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = var.backend_readonly_access_policy_arn
}

resource "aws_iam_role_policy_attachment" "reader_networking_access" {
  role       = aws_iam_role.kubernetes_ec2_reader
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_policy
}


data "aws_caller_identity" "current" {}
