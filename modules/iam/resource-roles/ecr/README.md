# ECR Resource Roles Module

This module creates IAM roles and policies specifically for managing AWS Elastic Container Registry (ECR) resources. It implements a role-based access control pattern with three levels of access:

1. **Creator Role**: Full permissions to create repositories and manage repository configurations
2. **Manager Role**: Permissions to push, pull, and manage images in existing repositories, but not create or delete repositories
3. **Reader Role**: Read-only access to repositories and images

The module provides optional support for:
- Restricting access to specific ECR repositories
- Enabling Kubernetes pod identity for pulling images from ECR

## Features

- Separate roles for creating, managing, and reading ECR resources
- Fine-grained IAM policies for each role
- Option to restrict access to specific ECR repositories
- Support for Kubernetes pod identity for ECR access
- Policies for repository lifecycle management, image scanning, and tag immutability

## Usage

### Basic Usage

```hcl
module "ecr_resource_roles" {
  source = "../../modules/iam/resource-roles/ecr"

  name_prefix       = "k8s"
  environment       = "dev"
  
  # Roles that can assume these ECR resource roles
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
}
```

### Restricting to Specific Repositories

```hcl
module "ecr_resource_roles" {
  source = "../../modules/iam/resource-roles/ecr"

  name_prefix       = "k8s"
  environment       = "dev"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Limit access to specific repositories
  specific_repository_arns = [
    "arn:aws:ecr:us-west-2:123456789012:repository/app1",
    "arn:aws:ecr:us-west-2:123456789012:repository/app2"
  ]
}
```

### Enabling Kubernetes Pod Identity for ECR

```hcl
module "ecr_resource_roles" {
  source = "../../modules/iam/resource-roles/ecr"

  name_prefix       = "k8s"
  environment       = "dev"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Enable Kubernetes pod identity for ECR access
  enable_kubernetes_pod_identity = true
}
```

## Integration with Meta-Roles

This module is designed to work with the meta-roles pattern. Meta-roles (creator, manager, reader) can assume these resource-specific roles to perform operations on ECR resources.

Example trust relationship:

```hcl
# In your environment configuration
module "meta_roles" {
  source = "../../modules/iam/meta-roles"
  # ... other parameters
}

module "ecr_resource_roles" {
  source = "../../modules/iam/resource-roles/ecr"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  # ... other parameters
}
```

## Kubernetes Pod Identity for ECR

When `enable_kubernetes_pod_identity` is set to `true`, this module includes additional permissions specifically for Kubernetes pods to pull images from ECR. This is useful for implementing IAM Roles for Service Accounts (IRSA) or for pods running on instances with attached IAM roles.

The permissions allow:
- Getting ECR authorization tokens
- Pulling images from ECR repositories
- Getting layer download URLs

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for naming resources | `string` | `"resource"` | no |
| trusted_role_arns | List of ARNs of IAM roles that can assume these roles | `list(string)` | `[]` | no |
| specific_repository_arns | List of specific ECR repository ARNs to restrict access to | `list(string)` | `[]` | no |
| enable_kubernetes_pod_identity | Whether to enable pod identity for ECR access | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecr_creator_role_arn | ARN of the ECR creator role |
| ecr_creator_role_name | Name of the ECR creator role |
| ecr_manager_role_arn | ARN of the ECR manager role |
| ecr_manager_role_name | Name of the ECR manager role |
| ecr_reader_role_arn | ARN of the ECR reader role |
| ecr_reader_role_name | Name of the ECR reader role |
| ecr_creator_policy_arn | ARN of the ECR creator policy |
| ecr_manager_policy_arn | ARN of the ECR manager policy |
| ecr_reader_policy_arn | ARN of the ECR reader policy |
| kubernetes_pod_ecr_policy_arn | ARN of the Kubernetes pod ECR policy (if enabled) |