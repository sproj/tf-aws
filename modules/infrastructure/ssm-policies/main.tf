data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ssm_read_document" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = ["arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.name_prefix}/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm_read" {
  name        = "${var.name_prefix}-ssm-read-policy"
  description = "Permissions for the EC2 instance role running k8s nodes to read from the Parameter Store for use with External Secret Operator"
  policy      = data.aws_iam_policy_document.ssm_read_document.json

  tags = {
    ManagedBy = data.aws_caller_identity.current.arn
  }
}

data "aws_iam_policy_document" "ssm_write_document" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:PutParameter",
    ]

    resources = [
      "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.name_prefix}/k8s-api/cluster_ca_certificate",
      "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.name_prefix}/k8s-api/client_certificate",
      "arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.name_prefix}/k8s-api/client_key",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ssm_write" {
  name        = "${var.name_prefix}-ssm-write-policy"
  description = "Permissions for the EC2 instance role running k8s nodes to write to the Parameter Store"
  policy      = data.aws_iam_policy_document.ssm_write_document.json

  tags = {
    ManagedBy = data.aws_caller_identity.current.arn
  }
}
