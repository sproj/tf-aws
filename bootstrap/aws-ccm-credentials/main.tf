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

resource "aws_iam_user" "aws-ccm-manager-user" {
  name = "aws-ccm-manager-user"

  tags = {
    ManagedBy   = "super-user"
    Environment = var.env
  }

}

data "aws_iam_policy_document" "aws_ccm_manager_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:AuthorizeSecurityGroupIngress", # open ports for load balancers
      "ec2:RevokeSecurityGroupIngress",    # close ports for load balancers
      "ec2:CreateSecurityGroup",
      "ec2:DeleteSecurityGroup"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "elasticloadbalancing:*" # create, describe, configure, delete load balancers
    ]
    resources = ["*"]
  }
  # The 'Allow' block on elasticloadbalancing should be a list of specific actions required by aws-ccm user.
  # That list is extensive enough that "*" is used as a drop-in
  # At least specifically deny the only action with account-wide consequences which i think i can do without denying the user actions it needs.
  # when the "allow" list is correct there will be no need for a 'deny' statement
  statement {
    effect    = "Deny"
    actions   = ["elasticloadbalancing:ModifyAccountAttributes"]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:Describe*",
      "ec2:CreateTags"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "aws_ccm_manager_policy" {
  name   = "aws-ccm-manager-user-policy"
  policy = data.aws_iam_policy_document.aws_ccm_manager_policy_document.json
  tags = {
    ManagedBy = "super-user"
  }
}

resource "aws_iam_user_policy_attachment" "aws_ccm_manager_attach" {
  user       = aws_iam_user.aws-ccm-manager-user.name
  policy_arn = aws_iam_policy.aws_ccm_manager_policy.arn
}

resource "aws_iam_access_key" "aws_ccm_manager_user_access_key" {
  user = aws_iam_user.aws-ccm-manager-user.name
}

resource "aws_ssm_parameter" "aws_ccm_manager_user_access_key_id" {
  name  = "/dev/dev-k8s/aws-ccm-manager-access-key-id"
  type  = "SecureString"
  value = aws_iam_access_key.aws_ccm_manager_user_access_key.id
}

resource "aws_ssm_parameter" "aws_ccm_manager_user_access_key_secret" {
  name  = "/dev/dev-k8s/aws-ccm-manager-secret-access-key"
  type  = "SecureString"
  value = aws_iam_access_key.aws_ccm_manager_user_access_key.secret
}
