resource "aws_iam_role" "deployment_role" {
  name = var.role_name

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
    Name      = var.role_name
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach creator backend access policy
resource "aws_iam_role_policy_attachment" "role_backend_access_policy" {
  role       = aws_iam_role.deployment_role.name
  policy_arn = var.backend_full_access_policy_arn
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "policy_document" {
  statement {
    effect    = "Allow"
    actions   = var.actions
    resources = ["*"]
  }
}

resource "aws_iam_policy" "policy" {
  name        = var.policy_name
  description = "Aggregated permissions for k8s-ec2 creator"
  policy      = data.aws_iam_policy_document.policy_document.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  role       = aws_iam_role.deployment_role.name
  policy_arn = aws_iam_policy.policy.arn
}
