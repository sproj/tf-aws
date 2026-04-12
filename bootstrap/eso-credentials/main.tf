terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "super-user"
}


resource "aws_iam_user" "eso-reader-user" {
  name = "eso-reader-user"

  tags = {
    ManagedBy   = "super-user"
    Environment = var.env
  }

}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "eso_reader_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
    ]
    resources = ["arn:aws:ssm:${var.aws_region}:${data.aws_caller_identity.current.account_id}:parameter/${var.env}/${var.env}-k8s/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeParameters"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "eso_reader_policy" {
  name   = "eso-reader-user-policy"
  policy = data.aws_iam_policy_document.eso_reader_policy_document.json
  tags = {
    ManagedBy = "super-user"
  }
}

resource "aws_iam_user_policy_attachment" "eso_reader_attach" {
  user       = aws_iam_user.eso-reader-user.name
  policy_arn = aws_iam_policy.eso_reader_policy.arn
}

resource "aws_iam_access_key" "eso_reader_user_access_key" {
  user = aws_iam_user.eso-reader-user.name
}

resource "aws_ssm_parameter" "eso_reader_user_access_key_id" {
  name  = "/dev/dev-k8s/eso-reader-ssm-access-key-id"
  type  = "SecureString"
  value = aws_iam_access_key.eso_reader_user_access_key.id
}

resource "aws_ssm_parameter" "eso_reader_user_access_key_secret" {
  name  = "/dev/dev-k8s/eso-reader-ssm-secret-access-key"
  type  = "SecureString"
  value = aws_iam_access_key.eso_reader_user_access_key.secret
}
