# IAM Resource Roles Module
# This module creates IAM roles and policies for IAM resource management

# IAM Creator Role - For creating and configuring IAM resources
resource "aws_iam_role" "iam_creator" {
  name = "${var.name_prefix}-iam-creator-role"

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
    Name        = "${var.name_prefix}-iam-creator-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# IAM Manager Role - For managing existing IAM resources
resource "aws_iam_role" "iam_manager" {
  name = "${var.name_prefix}-iam-manager-role"

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
    Name        = "${var.name_prefix}-iam-manager-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# IAM Reader Role - For read-only access to IAM resources
resource "aws_iam_role" "iam_reader" {
  name = "${var.name_prefix}-iam-reader-role"

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
    Name        = "${var.name_prefix}-iam-reader-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# IAM Creator Policy - Full permissions to create and configure IAM resources
resource "aws_iam_policy" "iam_creator_policy" {
  name        = "${var.name_prefix}-iam-creator-policy"
  description = "Policy for creating and configuring IAM resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # User operations
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:UpdateUser",
          "iam:TagUser",
          "iam:UntagUser",
          "iam:CreateLoginProfile",
          "iam:DeleteLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey",

          # Group operations
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:UpdateGroup",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",

          # Role operations
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",

          # Policy operations
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AttachGroupPolicy",
          "iam:DetachGroupPolicy",
          "iam:PutUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:PutGroupPolicy",
          "iam:DeleteGroupPolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",

          # SAML provider operations
          "iam:CreateSAMLProvider",
          "iam:UpdateSAMLProvider",
          "iam:DeleteSAMLProvider",

          # OpenID Connect provider operations
          "iam:CreateOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:AddClientIDToOpenIDConnectProvider",
          "iam:RemoveClientIDFromOpenIDConnectProvider",

          # Server certificate operations
          "iam:UploadServerCertificate",
          "iam:UpdateServerCertificate",
          "iam:DeleteServerCertificate",

          # Service-linked role operations
          "iam:CreateServiceLinkedRole",
          "iam:DeleteServiceLinkedRole",
          "iam:UpdateRoleDescription",

          # Identity provider operations
          "iam:CreateServiceSpecificCredential",
          "iam:UpdateServiceSpecificCredential",
          "iam:DeleteServiceSpecificCredential",
          "iam:ResetServiceSpecificCredential",

          # MFA operations
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:ResyncMFADevice",
          "iam:DeleteVirtualMFADevice",
          "iam:CreateVirtualMFADevice",

          # Permission boundary operations
          "iam:PutUserPermissionsBoundary",
          "iam:DeleteUserPermissionsBoundary",
          "iam:PutRolePermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary",

          # Read operations
          "iam:Get*",
          "iam:List*",
          "iam:GenerateCredentialReport",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:SimulateCustomPolicy",
          "iam:SimulatePrincipalPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Manager Policy - Permissions to manage existing IAM resources but not create or delete top-level resources
resource "aws_iam_policy" "iam_manager_policy" {
  name        = "${var.name_prefix}-iam-manager-policy"
  description = "Policy for managing existing IAM resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # User operations (update but not create/delete)
          "iam:UpdateUser",
          "iam:TagUser",
          "iam:UntagUser",
          "iam:UpdateLoginProfile",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey",

          # Group membership operations
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",

          # Role operations (update but not create/delete)
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",

          # Policy attachment operations
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AttachGroupPolicy",
          "iam:DetachGroupPolicy",
          "iam:PutUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:PutGroupPolicy",
          "iam:DeleteGroupPolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",

          # MFA operations
          "iam:EnableMFADevice",
          "iam:DeactivateMFADevice",
          "iam:ResyncMFADevice",

          # Read operations
          "iam:Get*",
          "iam:List*",
          "iam:GenerateCredentialReport",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:SimulateCustomPolicy",
          "iam:SimulatePrincipalPolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          # Deny creation/deletion of top-level resources
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreateSAMLProvider",
          "iam:DeleteSAMLProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Reader Policy - Read-only access to IAM resources
resource "aws_iam_policy" "iam_reader_policy" {
  name        = "${var.name_prefix}-iam-reader-policy"
  description = "Policy for read-only access to IAM resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:Get*",
          "iam:List*",
          "iam:GenerateCredentialReport",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:SimulateCustomPolicy",
          "iam:SimulatePrincipalPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

# Conditional policies for path-specific IAM resources if provided
resource "aws_iam_policy" "iam_creator_path_specific_policy" {
  count       = var.iam_path != "" ? 1 : 0
  name        = "${var.name_prefix}-iam-creator-path-specific-policy"
  description = "Policy for creating and configuring IAM resources in a specific path"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # User operations
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:UpdateUser",
          "iam:TagUser",
          "iam:UntagUser",
          "iam:CreateLoginProfile",
          "iam:DeleteLoginProfile",
          "iam:UpdateLoginProfile",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey",

          # Group operations
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:UpdateGroup",
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",

          # Role operations
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",

          # Policy operations for user, group, and role
          "iam:PutUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:PutGroupPolicy",
          "iam:DeleteGroupPolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy"
        ]
        Resource = [
          "arn:aws:iam::${var.account_id}:user${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:group${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:role${var.iam_path}*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # Policy operations
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AttachGroupPolicy",
          "iam:DetachGroupPolicy"
        ]
        Resource = [
          "arn:aws:iam::${var.account_id}:policy${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:user${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:group${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:role${var.iam_path}*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # Read operations
          "iam:Get*",
          "iam:List*",
          "iam:GenerateCredentialReport",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:SimulateCustomPolicy",
          "iam:SimulatePrincipalPolicy"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "iam_manager_path_specific_policy" {
  count       = var.iam_path != "" ? 1 : 0
  name        = "${var.name_prefix}-iam-manager-path-specific-policy"
  description = "Policy for managing existing IAM resources in a specific path"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # User operations (update but not create/delete)
          "iam:UpdateUser",
          "iam:TagUser",
          "iam:UntagUser",
          "iam:UpdateLoginProfile",
          "iam:CreateAccessKey",
          "iam:DeleteAccessKey",
          "iam:UpdateAccessKey",

          # Group membership operations
          "iam:AddUserToGroup",
          "iam:RemoveUserFromGroup",

          # Role operations (update but not create/delete)
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",

          # Policy operations for user, group, and role
          "iam:PutUserPolicy",
          "iam:DeleteUserPolicy",
          "iam:PutGroupPolicy",
          "iam:DeleteGroupPolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy"
        ]
        Resource = [
          "arn:aws:iam::${var.account_id}:user${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:group${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:role${var.iam_path}*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # Policy operations
          "iam:CreatePolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachUserPolicy",
          "iam:DetachUserPolicy",
          "iam:AttachGroupPolicy",
          "iam:DetachGroupPolicy"
        ]
        Resource = [
          "arn:aws:iam::${var.account_id}:policy${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:user${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:group${var.iam_path}*",
          "arn:aws:iam::${var.account_id}:role${var.iam_path}*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # Read operations
          "iam:Get*",
          "iam:List*",
          "iam:GenerateCredentialReport",
          "iam:GenerateServiceLastAccessedDetails",
          "iam:SimulateCustomPolicy",
          "iam:SimulatePrincipalPolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Deny"
        Action = [
          # Deny creation/deletion of top-level resources
          "iam:CreateUser",
          "iam:DeleteUser",
          "iam:CreateGroup",
          "iam:DeleteGroup",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreateSAMLProvider",
          "iam:DeleteSAMLProvider",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider"
        ]
        Resource = "*"
      }
    ]
  })
}

# Kubernetes IRSA policy for IAM
resource "aws_iam_policy" "kubernetes_irsa_policy" {
  count       = var.enable_kubernetes_irsa ? 1 : 0
  name        = "${var.name_prefix}-kubernetes-irsa-policy"
  description = "Policy for Kubernetes IAM Roles for Service Accounts (IRSA)"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # OIDC provider operations
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",

          # Role operations for service accounts
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:UpdateRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",

          # Policy operations for service account roles
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:GetRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies"
        ]
        Resource = [
          "arn:aws:iam::${var.account_id}:oidc-provider/*",
          var.irsa_role_path != "" ?
          "arn:aws:iam::${var.account_id}:role${var.irsa_role_path}*" :
          "arn:aws:iam::${var.account_id}:role/eks-*",
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:GetOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviders"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "iam_creator_policy_attachment" {
  role       = aws_iam_role.iam_creator.name
  policy_arn = var.iam_path != "" ? aws_iam_policy.iam_creator_path_specific_policy[0].arn : aws_iam_policy.iam_creator_policy.arn
}

resource "aws_iam_role_policy_attachment" "iam_manager_policy_attachment" {
  role       = aws_iam_role.iam_manager.name
  policy_arn = var.iam_path != "" ? aws_iam_policy.iam_manager_path_specific_policy[0].arn : aws_iam_policy.iam_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "iam_reader_policy_attachment" {
  role       = aws_iam_role.iam_reader.name
  policy_arn = aws_iam_policy.iam_reader_policy.arn
}

# Attach Kubernetes IRSA policy if enabled
resource "aws_iam_role_policy_attachment" "kubernetes_irsa_attachment" {
  count      = var.enable_kubernetes_irsa ? 1 : 0
  role       = aws_iam_role.iam_creator.name
  policy_arn = aws_iam_policy.kubernetes_irsa_policy[0].arn
}
