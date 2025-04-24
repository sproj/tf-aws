# ECR Resource Roles Module
# This module creates IAM roles and policies for ECR repository management

# ECR Creator Role - For creating and configuring ECR repositories
resource "aws_iam_role" "ecr_creator" {
  name = "${var.name_prefix}-ecr-creator-role"

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
    Name        = "${var.name_prefix}-ecr-creator-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# ECR Manager Role - For managing images in existing repositories
resource "aws_iam_role" "ecr_manager" {
  name = "${var.name_prefix}-ecr-manager-role"

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
    Name        = "${var.name_prefix}-ecr-manager-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# ECR Reader Role - For read-only access to ECR repositories
resource "aws_iam_role" "ecr_reader" {
  name = "${var.name_prefix}-ecr-reader-role"

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
    Name        = "${var.name_prefix}-ecr-reader-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# ECR Creator Policy - Full permissions to create and configure ECR repositories
resource "aws_iam_policy" "ecr_creator_policy" {
  name        = "${var.name_prefix}-ecr-creator-policy"
  description = "Policy for creating and configuring ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Repository operations
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability",
          "ecr:PutLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",
          "ecr:PutReplicationConfiguration",

          # Image operations
          "ecr:PutImage",
          "ecr:BatchDeleteImage",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:BatchCheckLayerAvailability",

          # Tag operations
          "ecr:TagResource",
          "ecr:UntagResource",

          # Read operations
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECR Manager Policy - Permissions to manage images in existing repositories
resource "aws_iam_policy" "ecr_manager_policy" {
  name        = "${var.name_prefix}-ecr-manager-policy"
  description = "Policy for managing images in existing ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Repository configuration
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability",
          "ecr:PutLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",

          # Image operations
          "ecr:PutImage",
          "ecr:BatchDeleteImage",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:BatchCheckLayerAvailability",

          # Tag operations
          "ecr:TagResource",
          "ecr:UntagResource",

          # Read operations
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "ecr:CreateRepository",
          "ecr:DeleteRepository"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECR Reader Policy - Read-only access to ECR repositories
resource "aws_iam_policy" "ecr_reader_policy" {
  name        = "${var.name_prefix}-ecr-reader-policy"
  description = "Policy for read-only access to ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

# Conditional policy for specific repositories if provided
resource "aws_iam_policy" "ecr_creator_specific_repos_policy" {
  count       = length(var.specific_repository_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-ecr-creator-specific-repos-policy"
  description = "Policy for creating and configuring specific ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Repository operations
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability",
          "ecr:PutLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",

          # Image operations
          "ecr:PutImage",
          "ecr:BatchDeleteImage",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:BatchCheckLayerAvailability",

          # Tag operations
          "ecr:TagResource",
          "ecr:UntagResource"
        ]
        Resource = var.specific_repository_arns
      },
      {
        Effect = "Allow"
        Action = [
          # Read operations
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_manager_specific_repos_policy" {
  count       = length(var.specific_repository_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-ecr-manager-specific-repos-policy"
  description = "Policy for managing images in specific ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Repository configuration
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability",
          "ecr:PutLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",

          # Image operations
          "ecr:PutImage",
          "ecr:BatchDeleteImage",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:BatchCheckLayerAvailability",

          # Tag operations
          "ecr:TagResource",
          "ecr:UntagResource"
        ]
        Resource = var.specific_repository_arns
      },
      {
        Effect = "Allow"
        Action = [
          # Read operations
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "ecr:CreateRepository",
          "ecr:DeleteRepository"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecr_reader_specific_repos_policy" {
  count       = length(var.specific_repository_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-ecr-reader-specific-repos-policy"
  description = "Policy for read-only access to specific ECR repositories"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:DescribeImages",
          "ecr:ListImages",
          "ecr:GetLifecyclePolicy",
          "ecr:GetLifecyclePolicyPreview",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource"
        ]
        Resource = var.specific_repository_arns
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      }
    ]
  })
}

# Kubernetes Pod Identity Policy for ECR access
resource "aws_iam_policy" "kubernetes_pod_ecr_policy" {
  count       = var.enable_kubernetes_pod_identity ? 1 : 0
  name        = "${var.name_prefix}-kubernetes-pod-ecr-policy"
  description = "Policy for Kubernetes pods to pull images from ECR"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Resource = length(var.specific_repository_arns) > 0 ? var.specific_repository_arns : ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "ecr_creator_policy_attachment" {
  role       = aws_iam_role.ecr_creator.name
  policy_arn = length(var.specific_repository_arns) > 0 ? aws_iam_policy.ecr_creator_specific_repos_policy[0].arn : aws_iam_policy.ecr_creator_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_manager_policy_attachment" {
  role       = aws_iam_role.ecr_manager.name
  policy_arn = length(var.specific_repository_arns) > 0 ? aws_iam_policy.ecr_manager_specific_repos_policy[0].arn : aws_iam_policy.ecr_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecr_reader_policy_attachment" {
  role       = aws_iam_role.ecr_reader.name
  policy_arn = length(var.specific_repository_arns) > 0 ? aws_iam_policy.ecr_reader_specific_repos_policy[0].arn : aws_iam_policy.ecr_reader_policy.arn
}

# Attach Kubernetes pod identity policy if enabled
resource "aws_iam_role_policy_attachment" "kubernetes_pod_ecr_attachment" {
  count      = var.enable_kubernetes_pod_identity ? 1 : 0
  role       = aws_iam_role.ecr_reader.name
  policy_arn = aws_iam_policy.kubernetes_pod_ecr_policy[0].arn
}
