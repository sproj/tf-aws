data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ssm_read" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "ssm:DescribeParameters",
    ]
    resources = ["arn:aws:ssm:eu-west-1:${data.aws_caller_identity.current.account_id}:parameter/dev/dev-k8s/*"]
  }
}

resource "aws_iam_policy" "ssm_read" {
  name        = "${var.name_prefix}-ssm-read-policy"
  description = "Permissions for the EC2 instance role running k8s nodes to interact with the Parameter Store for use with External Secret Operator"
  policy      = data.aws_iam_policy_document.ssm_read.json

  tags = {
    ManagedBy = data.aws_caller_identity.current.arn
  }
}
