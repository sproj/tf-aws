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

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "bootstrap/dns/terraform.tfstate"
    region  = "eu-west-1"
    profile = "super-user"
  }
}

resource "aws_iam_user" "cert-manager-user" {
  name = "cert-manager-user"

  tags = {
    ManagedBy   = "super-user"
    Environment = var.env
  }

}

data "aws_iam_policy_document" "cert_manager_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets"
    ]
    resources = ["arn:aws:route53:::hostedzone/${data.terraform_remote_state.dns.outputs.zone_id}"]
  }
  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZonesByName", "route53:GetChange"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cert_manager_policy" {
  name   = "cert-manager-user-policy"
  policy = data.aws_iam_policy_document.cert_manager_policy_document.json
  tags = {
    ManagedBy = "super-user"
  }
}

resource "aws_iam_user_policy_attachment" "cert_manager_attach" {
  user       = aws_iam_user.cert-manager-user.name
  policy_arn = aws_iam_policy.cert_manager_policy.arn
}

resource "aws_iam_access_key" "cert_manager_user_access_key" {
  user = aws_iam_user.cert-manager-user.name
}

resource "aws_ssm_parameter" "cert_manager_user_access_key_id" {
  name = "/dev/dev-k8s/cert-manager-route-53-access-key-id"
  type = "SecureString"
  value = aws_iam_access_key.cert_manager_user_access_key.id
}

resource "aws_ssm_parameter" "cert_manager_user_access_key_secret" {
  name = "/dev/dev-k8s/cert-manager-route-53-secret-access-key"
  type = "SecureString"
  value = aws_iam_access_key.cert_manager_user_access_key.secret
}