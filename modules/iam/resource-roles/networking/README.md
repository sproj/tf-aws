# Networking Resource Roles Module

This module creates IAM roles and policies specifically for managing AWS networking resources. It implements a role-based access control pattern with three levels of access:

1. **Creator Role**: Full permissions to provision and configure VPCs, subnets, routing tables, security groups, load balancers, and other networking components
2. **Manager Role**: Permissions to manage existing networking resources
3. **Reader Role**: Read-only access to networking resources

The module also provides optional support for Kubernetes-specific networking permissions required for components like the AWS Load Balancer Controller and CNI plugins.

## Features

- Separate roles for creating, managing, and reading networking resources
- Fine-grained IAM policies for each role
- Support for various networking resources:
  - VPCs and VPC endpoints
  - Subnets and route tables
  - Security groups and network ACLs
  - Internet and NAT gateways
  - Elastic Load Balancers
  - Transit Gateways
  - VPN connections and Direct Connect
- Optional additional permissions for Kubernetes networking components

## Usage

```hcl
module "networking_resource_roles" {
  source = "../../modules/iam/resource-roles/networking"

  name_prefix       = "k8s"
  environment       = "dev"
  
  # Roles that can assume these networking resource roles
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Enable additional permissions for Kubernetes networking
  enable_kubernetes_networking = true
}
```

## Integration with Meta-Roles

This module is designed to work with the meta-roles pattern. Meta-roles (creator, manager, reader) can assume these resource-specific roles to perform operations on networking resources.

Example trust relationship:

```hcl
# In your environment configuration
module "meta_roles" {
  source = "../../modules/iam/meta-roles"
  # ... other parameters
}

module "networking_resource_roles" {
  source = "../../modules/iam/resource-roles/networking"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  # ... other parameters
}
```

## Kubernetes Networking Support

When `enable_kubernetes_networking` is set to `true`, this module includes additional permissions required for Kubernetes networking components:

- **AWS Load Balancer Controller**: Permissions for creating and managing Application Load Balancers (ALBs) and Network Load Balancers (NLBs)
- **Container Network Interface (CNI) plugins**: Permissions for managing network interfaces, private IP addresses, and other networking resources needed by Kubernetes pods

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for naming resources | `string` | `"resource"` | no |
| trusted_role_arns | List of ARNs of IAM roles that can assume these roles | `list(string)` | `[]` | no |
| enable_kubernetes_networking | Whether to enable Kubernetes networking permissions | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| networking_creator_role_arn | ARN of the networking creator role |
| networking_creator_role_name | Name of the networking creator role |
| networking_manager_role_arn | ARN of the networking manager role |
| networking_manager_role_name | Name of the networking manager role |
| networking_reader_role_arn | ARN of the networking reader role |
| networking_reader_role_name | Name of the networking reader role |
| networking_creator_policy_arn | ARN of the networking creator policy |
| networking_manager_policy_arn | ARN of the networking manager policy |
| networking_reader_policy_arn | ARN of the networking reader policy |
| kubernetes_networking_policy_arn | ARN of the Kubernetes networking policy (if enabled) |