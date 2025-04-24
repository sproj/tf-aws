# IAM Resource Roles Module

This module creates IAM roles and policies specifically for managing AWS IAM resources. It implements a role-based access control pattern with three levels of access:

1. **Creator Role**: Full permissions to create and configure IAM users, groups, roles, and policies
2. **Manager Role**: Permissions to manage existing IAM resources but not create or delete top-level resources
3. **Reader Role**: Read-only access to IAM resources

The module provides optional support for:
- Restricting permissions to specific IAM paths
- Enabling Kubernetes IAM Roles for Service Accounts (IRSA) permissions

## Features

- Separate roles for creating, managing, and reading IAM resources
- Fine-grained IAM policies for each role
- Option to restrict permissions to specific IAM paths
- Support for Kubernetes IRSA implementation
- Comprehensive permissions for users, groups, roles, policies, SAML providers, and OIDC providers

## Usage

### Basic Usage

```hcl
module "iam_resource_roles" {
  source = "../../modules/iam/resource-roles/iam"

  name_prefix       = "k8s"
  environment       = "dev"
  account_id        = "123456789012"
  
  # Roles that can assume these IAM resource roles
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
}
```

### Restricting to Specific IAM Paths

```hcl
module "iam_resource_roles" {
  source = "../../modules/iam/resource-roles/iam"

  name_prefix       = "k8s"
  environment       = "dev"
  account_id        = "123456789012"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Limit permissions to a specific IAM path
  iam_path          = "/kubernetes/"
}
```

### Enabling Kubernetes IRSA Support

```hcl
module "iam_resource_roles" {
  source = "../../modules/iam/resource-roles/iam"

  name_prefix       = "k8s"
  environment       = "dev"
  account_id        = "123456789012"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Enable IRSA permissions
  enable_kubernetes_irsa = true
  irsa_role_path         = "/eks-service-accounts/"
}
```

## Integration with Meta-Roles

This module is designed to work with the meta-roles pattern. Meta-roles (creator, manager, reader) can assume these resource-specific roles to perform operations on IAM resources.

Example trust relationship:

```hcl
# In your environment configuration
module "meta_roles" {
  source = "../../modules/iam/meta-roles"
  # ... other parameters
}

module "iam_resource_roles" {
  source = "../../modules/iam/resource-roles/iam"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  # ... other parameters
}
```

## IAM Path Restrictions

When `iam_path` is specified, the module creates policies that restrict operations to IAM resources in that path. This allows for better isolation and separation of concerns, especially in environments with multiple teams or applications.

For example, setting `iam_path = "/kubernetes/"` restricts operations to IAM resources with paths like:
- `/kubernetes/`
- `/kubernetes/worker-nodes/`
- `/kubernetes/service-accounts/`

## Kubernetes IRSA Support

When `enable_kubernetes_irsa` is set to `true`, this module includes additional permissions specifically for implementing IAM Roles for Service Accounts (IRSA) in Kubernetes. IRSA allows Kubernetes service accounts to assume IAM roles, enabling fine-grained access control for pods.

The permissions enable:
- Creating and managing OIDC providers for EKS clusters
- Creating and managing IAM roles that can be assumed by Kubernetes service accounts
- Attaching policies to those roles

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| account_id | AWS account ID where the roles will be created | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for naming