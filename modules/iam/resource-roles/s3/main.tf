# S3 Resource Roles Module
# This module creates IAM roles and policies for S3 bucket management

# S3 Creator Role - For creating and configuring S3 buckets
resource "aws_iam_role" "s3_creator" {
  name = "${var.name_prefix}-s3-creator-role"

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
    Name        = "${var.name_prefix}-s3-creator-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# S3 Manager Role - For managing objects in existing buckets
resource "aws_iam_role" "s3_manager" {
  name = "${var.name_prefix}-s3-manager-role"

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
    Name        = "${var.name_prefix}-s3-manager-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# S3 Reader Role - For read-only access to S3 buckets
resource "aws_iam_role" "s3_reader" {
  name = "${var.name_prefix}-s3-reader-role"

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
    Name        = "${var.name_prefix}-s3-reader-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# S3 Creator Policy - Full permissions to create and configure S3 buckets
resource "aws_iam_policy" "s3_creator_policy" {
  name        = "${var.name_prefix}-s3-creator-policy"
  description = "Policy for creating and configuring S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Bucket operations
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketAcl",
          "s3:PutBucketVersioning",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketLogging",
          "s3:PutBucketEncryption",
          "s3:PutBucketReplication",
          "s3:PutBucketCors",
          "s3:PutBucketTagging",
          "s3:PutBucketNotification",
          "s3:PutBucketWebsite",
          "s3:PutBucketLifecycle",
          "s3:PutBucketOwnershipControls",
          "s3:PutBucketIntelligentTieringConfiguration",
          "s3:PutBucketMetricsConfiguration",
          "s3:PutBucketAnalyticsConfiguration",
          "s3:PutBucketInventoryConfiguration",

          # Object operations
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging",

          # List operations
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads",
          "s3:ListAllMyBuckets",

          # Other operations
          "s3:AbortMultipartUpload",
          "s3:RestoreObject"
        ]
        Resource = "*"
      }
    ]
  })
}

# Conditional policy for restricting to specific buckets if provided
resource "aws_iam_policy" "s3_creator_specific_buckets_policy" {
  count       = length(var.specific_bucket_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-s3-creator-specific-buckets-policy"
  description = "Policy for creating and configuring specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Bucket operations
          "s3:CreateBucket",
          "s3:DeleteBucket",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketAcl",
          "s3:PutBucketVersioning",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketLogging",
          "s3:PutBucketEncryption",
          "s3:PutBucketReplication",
          "s3:PutBucketCors",
          "s3:PutBucketTagging",
          "s3:PutBucketNotification",
          "s3:PutBucketWebsite",
          "s3:PutBucketLifecycle",
          "s3:PutBucketOwnershipControls",
          "s3:PutBucketIntelligentTieringConfiguration",
          "s3:PutBucketMetricsConfiguration",
          "s3:PutBucketAnalyticsConfiguration",
          "s3:PutBucketInventoryConfiguration"
        ]
        Resource = var.specific_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          # Object operations
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [for arn in var.specific_bucket_arns : "${arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          # List operations
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = var.specific_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3 Manager Policy - Permissions to manage objects in existing buckets
resource "aws_iam_policy" "s3_manager_policy" {
  name        = "${var.name_prefix}-s3-manager-policy"
  description = "Policy for managing objects in existing S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Bucket configuration
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketAcl",
          "s3:PutBucketVersioning",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketLogging",
          "s3:PutBucketEncryption",
          "s3:PutBucketReplication",
          "s3:PutBucketCors",
          "s3:PutBucketTagging",
          "s3:PutBucketNotification",
          "s3:PutBucketWebsite",
          "s3:PutBucketLifecycle",
          "s3:PutBucketOwnershipControls",

          # Object operations
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging",

          # List operations
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads",
          "s3:ListAllMyBuckets",

          # Other operations
          "s3:AbortMultipartUpload",
          "s3:RestoreObject"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          "s3:CreateBucket",
          "s3:DeleteBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

# Conditional policy for restricting to specific buckets if provided
resource "aws_iam_policy" "s3_manager_specific_buckets_policy" {
  count       = length(var.specific_bucket_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-s3-manager-specific-buckets-policy"
  description = "Policy for managing objects in specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Bucket configuration
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketAcl",
          "s3:PutBucketVersioning",
          "s3:PutBucketPublicAccessBlock",
          "s3:PutBucketLogging",
          "s3:PutBucketEncryption",
          "s3:PutBucketReplication",
          "s3:PutBucketCors",
          "s3:PutBucketTagging",
          "s3:PutBucketNotification",
          "s3:PutBucketWebsite",
          "s3:PutBucketLifecycle",
          "s3:PutBucketOwnershipControls"
        ]
        Resource = var.specific_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          # Object operations
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging",

          # Other operations
          "s3:AbortMultipartUpload",
          "s3:RestoreObject"
        ]
        Resource = [for arn in var.specific_bucket_arns : "${arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          # List operations
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = var.specific_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3 Reader Policy - Read-only access to S3 buckets
resource "aws_iam_policy" "s3_reader_policy" {
  name        = "${var.name_prefix}-s3-reader-policy"
  description = "Policy for read-only access to S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging",
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetBucketVersioning",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketLogging",
          "s3:GetBucketEncryption",
          "s3:GetBucketReplication",
          "s3:GetBucketCors",
          "s3:GetBucketTagging",
          "s3:GetBucketNotification",
          "s3:GetBucketWebsite",
          "s3:GetBucketLifecycle"
        ]
        Resource = "*"
      }
    ]
  })
}

# Conditional policy for restricting to specific buckets if provided
resource "aws_iam_policy" "s3_reader_specific_buckets_policy" {
  count       = length(var.specific_bucket_arns) > 0 ? 1 : 0
  name        = "${var.name_prefix}-s3-reader-specific-buckets-policy"
  description = "Policy for read-only access to specific S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetObjectAcl",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:GetObjectVersionTagging"
        ]
        Resource = [for arn in var.specific_bucket_arns : "${arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:GetBucketLocation",
          "s3:GetBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetBucketVersioning",
          "s3:GetBucketPublicAccessBlock",
          "s3:GetBucketLogging",
          "s3:GetBucketEncryption",
          "s3:GetBucketReplication",
          "s3:GetBucketCors",
          "s3:GetBucketTagging",
          "s3:GetBucketNotification",
          "s3:GetBucketWebsite",
          "s3:GetBucketLifecycle"
        ]
        Resource = var.specific_bucket_arns
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListAllMyBuckets"
        ]
        Resource = "*"
      }
    ]
  })
}

# Kubernetes etcd backup policy
resource "aws_iam_policy" "kubernetes_etcd_backup_policy" {
  count       = var.enable_kubernetes_etcd_backup ? 1 : 0
  name        = "${var.name_prefix}-kubernetes-etcd-backup-policy"
  description = "Policy for Kubernetes etcd backup to S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = var.etcd_backup_bucket_arn != "" ? [
          var.etcd_backup_bucket_arn,
          "${var.etcd_backup_bucket_arn}/*"
        ] : []
      }
    ]
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "s3_creator_policy_attachment" {
  role       = aws_iam_role.s3_creator.name
  policy_arn = length(var.specific_bucket_arns) > 0 ? aws_iam_policy.s3_creator_specific_buckets_policy[0].arn : aws_iam_policy.s3_creator_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_manager_policy_attachment" {
  role       = aws_iam_role.s3_manager.name
  policy_arn = length(var.specific_bucket_arns) > 0 ? aws_iam_policy.s3_manager_specific_buckets_policy[0].arn : aws_iam_policy.s3_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "s3_reader_policy_attachment" {
  role       = aws_iam_role.s3_reader.name
  policy_arn = length(var.specific_bucket_arns) > 0 ? aws_iam_policy.s3_reader_specific_buckets_policy[0].arn : aws_iam_policy.s3_reader_policy.arn
}

# Attach Kubernetes etcd backup policy if enabled
resource "aws_iam_role_policy_attachment" "s3_creator_etcd_backup_attachment" {
  count      = var.enable_kubernetes_etcd_backup ? 1 : 0
  role       = aws_iam_role.s3_creator.name
  policy_arn = aws_iam_policy.kubernetes_etcd_backup_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "s3_manager_etcd_backup_attachment" {
  count      = var.enable_kubernetes_etcd_backup ? 1 : 0
  role       = aws_iam_role.s3_manager.name
  policy_arn = aws_iam_policy.kubernetes_etcd_backup_policy[0].arn
}
