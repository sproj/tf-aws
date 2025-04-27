# Kubernetes on EC2 Deployment Type

This module creates the necessary IAM roles and policies for running a Kubernetes cluster on EC2 instances.

## Features

- Creates IAM roles for EC2 instances acting as Kubernetes worker nodes
- Provides necessary permissions for EC2, ELB, ECR, and other AWS services
- Optionally supports IAM Roles for Service Accounts (IRSA) for fine-grained pod permissions
- Includes integration with AWS SSM for instance management

## Usage

```hcl
module "kubernetes_ec2_roles" {
  source = "../../modules/iam/deployment-type-roles/kubernetes-ec2"

  name_prefix = "my-cluster"
  environment = "dev"
  
  # Enable IRSA for pod-level IAM permissions
  enable_irsa                  = true
  eks_oidc_issuer_url          = "https://oidc.eks.us-west-2.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
  eks_oidc_provider_thumbprint = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  
  # Additional policies to attach if needed
  additional_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}
```

## IRSA (IAM Roles for Service Accounts)

When `enable_irsa` is set to `true`, this module creates an IAM OIDC provider that allows Kubernetes service accounts to assume IAM roles. This enables a more secure and fine-grained approach to IAM permissions at the pod level.

To use IRSA:

1. Create service account roles in your Terraform code:

```hcl
resource "aws_iam_role" "service_account_role" {
  name = "k8s-service-account-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = module.kubernetes_ec2_roles.kubernetes_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${replace(module.kubernetes_ec2_roles.eks_oidc_issuer_url, "https://", "")}:sub": "system:serviceaccount:default:my-service-account"
          }
        }
      }
    ]
  })
}
```

2. Create a Kubernetes service account that references this role:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/k8s-service-account-role
```

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for naming resources | `string` | `"k8s"` | no |
| enable_irsa | Whether to enable IAM Roles for Service Accounts | `bool` | `false` | no |
| eks_oidc_issuer_url | OIDC issuer URL for the EKS cluster | `string` | `""` | no |
| eks_oidc_provider_thumbprint | Thumbprint of the OIDC provider | `list(string)` | `[]` | no |
| additional_policy_arns | List of additional policy ARNs to attach | `list(string)` | `[]` | no |
| aws_region | AWS region for resources | `string` | `"us-west-2"` | no |
| vpc_id | ID of the VPC for Kubernetes | `string` | `""` | no |
| subnet_ids | List of subnet IDs for Kubernetes | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| kubernetes_worker_role_arn | ARN of the Kubernetes worker IAM role |
| kubernetes_worker_role_name | Name of the Kubernetes worker IAM role |
| kubernetes_worker_instance_profile_arn | ARN of the Kubernetes worker instance profile |
| kubernetes_worker_instance_profile_name | Name of the Kubernetes worker instance profile |
| kubernetes_oidc_provider_arn | ARN of the OIDC provider for IRSA (if enabled) |
| kubernetes_ec2_policy_arn | ARN of the EC2 policy |
| kubernetes_elb_policy_arn | ARN of the ELB policy |
| kubernetes_ecr_policy_arn | ARN of the ECR policy |
| kubernetes_iam_auth_policy_arn | ARN of the IAM Authenticator policy |