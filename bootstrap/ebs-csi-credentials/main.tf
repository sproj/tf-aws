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


resource "aws_iam_user" "ebs_csi_user" {
  name = "ebs-csi-user"

  tags = {
    ManagedBy   = "super-user"
    Environment = var.env
  }

}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ebs_csi_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:CreateTags",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSnapshots",
      "ec2:DescribeTags",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ebs_csi_policy" {
  name   = "ebs-csi-user-policy"
  policy = data.aws_iam_policy_document.ebs_csi_policy_document.json
  tags = {
    ManagedBy = "super-user"
  }
}

resource "aws_iam_user_policy_attachment" "ebs_csi_policy_attach" {
  user       = aws_iam_user.ebs_csi_user.name
  policy_arn = aws_iam_policy.ebs_csi_policy.arn
}

resource "aws_iam_access_key" "ebs_csi_user_access_key" {
  user = aws_iam_user.ebs_csi_user.name
}

resource "aws_ssm_parameter" "ebs_csi_user_access_key_id" {
  name  = "/dev/dev-k8s/ebs-csi-ec2-access-key-id"
  type  = "SecureString"
  value = aws_iam_access_key.ebs_csi_user_access_key.id
}

resource "aws_ssm_parameter" "ebs_csi_user_access_key_secret" {
  name  = "/dev/dev-k8s/ebs-csi-ec2-secret-access-key"
  type  = "SecureString"
  value = aws_iam_access_key.ebs_csi_user_access_key.secret
}
