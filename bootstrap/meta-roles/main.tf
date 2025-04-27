terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "terraform_remote_state" "state_backend" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "bootstrap/terraform.tfstate"
    region  = "eu-west-1"
    profile = "super-user"
  }
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "infrastructure_manager" {
  name = "infrastructure-manager"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${var.bootstrapper_user_name}"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Terraform = "true"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_policy" "infrastructure_manager_policy" {
  name        = "infrastructure-manager-policy"
  description = "Allows creation and management of IAM roles and policies for infrastructure deployments."
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:UpdateRole",
          "iam:PassRole",
          "iam:TagRole",
          "iam:AttachRolePolicy",
          "iam:GetPolicyVersion",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:TagPolicy",
          "iam:ListPolicies",
          "iam:ListRoles",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListPolicyVersions",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole"
        ],
        Resource = "*"
      }
    ]
  })

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_role_policy_attachment" "infrastructure_manager_attach" {
  role       = aws_iam_role.infrastructure_manager.name
  policy_arn = aws_iam_policy.infrastructure_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "infrastructure_manager_backend_access" {
  role       = aws_iam_role.infrastructure_manager.name
  policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
}
