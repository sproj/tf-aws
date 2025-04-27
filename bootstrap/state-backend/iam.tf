resource "aws_iam_policy" "terraform_backend_full_access" {
  name        = "terraform-backend-full-access"
  description = "Full access to Terraform backend S3 bucket and DynamoDB lock table"
  policy      = data.aws_iam_policy_document.terraform_backend_full_access.json
  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

data "aws_iam_policy_document" "terraform_backend_full_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::tfaws-dev-state-backend",
      "arn:aws:s3:::tfaws-dev-state-backend/*"
    ]
  }

  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
      "dynamodb:UpdateItem"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/tfaws-dev-lock-backend"
    ]
  }
}


resource "aws_iam_policy" "terraform_backend_readonly_access" {
  name        = "terraform-backend-readonly-access"
  description = "Read-only access to Terraform backend S3 bucket and DynamoDB lock table"
  policy      = data.aws_iam_policy_document.terraform_backend_readonly_access.json
  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

data "aws_iam_policy_document" "terraform_backend_readonly_access" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::tfaws-dev-state-backend",
      "arn:aws:s3:::tfaws-dev-state-backend/*"
    ]
  }

  statement {
    actions = [
      "dynamodb:GetItem"
    ]
    resources = [
      "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/tfaws-dev-lock-backend"
    ]
  }
}

data "aws_caller_identity" "current" {}
