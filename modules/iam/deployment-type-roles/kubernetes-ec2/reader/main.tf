resource "aws_iam_role" "kubernetes_ec2_reader" {
  name = "${var.name_prefix}-k8s-ec2-reader"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.bootstrapper_user_name}"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name      = "${var.name_prefix}-k8s-ec2-reader"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_policy" "kubernetes_ec2_reader_policy" {
  name = "${var.name_prefix}-k8s-ec2-reader-policy"

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
}

resource "aws_iam_role_policy_attachment" "reader_attach" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_policy.arn
}

data "aws_caller_identity" "current" {}
