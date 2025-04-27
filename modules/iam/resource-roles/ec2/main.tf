# EC2 Resource Roles Module
# This module creates IAM roles and policies for EC2 resource management

# EC2 Creator Role - For provisioning EC2 instances
resource "aws_iam_role" "ec2_creator" {
  name = "${var.name_prefix}-ec2-creator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_role_arns
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ec2-creator-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# EC2 Manager Role - For managing existing EC2 instances
resource "aws_iam_role" "ec2_manager" {
  name = "${var.name_prefix}-ec2-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_role_arns
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ec2-manager-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# EC2 Reader Role - For read-only access to EC2 resources
resource "aws_iam_role" "ec2_reader" {
  name = "${var.name_prefix}-ec2-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_role_arns
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-ec2-reader-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# EC2 Creator Policy - Full permissions to create and configure EC2 resources
resource "aws_iam_policy" "ec2_creator_policy" {
  name        = "${var.name_prefix}-ec2-creator-policy"
  description = "Policy for creating and configuring EC2 resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:RunInstances",
          "ec2:RequestSpotInstances",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:CreateSecurityGroup",
          "ec2:CreateNetworkInterface",
          "ec2:CreateSnapshot",
          "ec2:CreateImage",
          "ec2:CreateKeyPair",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:ImportKeyPair",
          "ec2:AllocateAddress",
          "ec2:AssociateAddress",
          "ec2:ImportImage",
          "ec2:CopyImage",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeVolumes",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSnapshots",
          "ec2:DescribeImages",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeAddresses",
          "ec2:DescribeRegions",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeTags"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "arn:aws:iam::${var.account_id}:role/${var.name_prefix}-ec2-*"
      }
    ]
  })
}

# EC2 Manager Policy - Permissions to manage existing EC2 instances
resource "aws_iam_policy" "ec2_manager_policy" {
  name        = "${var.name_prefix}-ec2-manager-policy"
  description = "Policy for managing existing EC2 resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:RebootInstances",
          "ec2:TerminateInstances",
          "ec2:AttachVolume",
          "ec2:DetachVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyVolume",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVolume",
          "ec2:DeleteSnapshot",
          "ec2:DeleteKeyPair",
          "ec2:DeleteLaunchTemplate",
          "ec2:ReleaseAddress",
          "ec2:DisassociateAddress",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeVolumes",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSnapshots",
          "ec2:DescribeImages",
          "ec2:DescribeKeyPairs",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:DescribeAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

# EC2 Reader Policy - Read-only access to EC2 resources
resource "aws_iam_policy" "ec2_reader_policy" {
  name        = "${var.name_prefix}-ec2-reader-policy"
  description = "Policy for read-only access to EC2 resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:Get*"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "ec2_creator_policy_attachment" {
  role       = aws_iam_role.ec2_creator.name
  policy_arn = aws_iam_policy.ec2_creator_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_manager_policy_attachment" {
  role       = aws_iam_role.ec2_manager.name
  policy_arn = aws_iam_policy.ec2_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_reader_policy_attachment" {
  role       = aws_iam_role.ec2_reader.name
  policy_arn = aws_iam_policy.ec2_reader_policy.arn
}

# SSM Access policy for instance management via Systems Manager
resource "aws_iam_policy" "ec2_ssm_access_policy" {
  count       = var.enable_ssm_access ? 1 : 0
  name        = "${var.name_prefix}-ec2-ssm-access-policy"
  description = "Policy for accessing EC2 instances via SSM"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:StartSession",
          "ssm:TerminateSession",
          "ssm:ResumeSession",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ssm:DescribeInstanceProperties",
          "ssm:DescribeInstanceInformation"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach SSM access policy if enabled
resource "aws_iam_role_policy_attachment" "ec2_creator_ssm_attachment" {
  count      = var.enable_ssm_access ? 1 : 0
  role       = aws_iam_role.ec2_creator.name
  policy_arn = aws_iam_policy.ec2_ssm_access_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "ec2_manager_ssm_attachment" {
  count      = var.enable_ssm_access ? 1 : 0
  role       = aws_iam_role.ec2_manager.name
  policy_arn = aws_iam_policy.ec2_ssm_access_policy[0].arn
}
