# EC2 Resource Roles Module

This module creates IAM roles and policies specifically for managing EC2 resources. It implements a role-based access control pattern with three levels of access:

1. **Creator Role**: Full permissions to provision and configure EC2 instances and related resources
2. **Manager Role**: Permissions to manage existing EC2 instances and resources
3. **Reader Role**: Read-only access to EC2 resources

## Features

- Separate roles for creating, managing, and reading EC2 resources
- Fine-grained IAM policies for each role
- Optional Systems Manager (SSM) access for connecting to instances
- Customizable trust relationships for role assumption

## Usage

```hcl
module "ec2_resource_roles" {
  source = "../../modules/iam/resource-roles/ec2"

  name_prefix       = "k8s"
  environment       = "dev"
  account_id        = "123456789012"
  
  # Roles that can assume these EC2 resource roles
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Enable SSM access for console-based instance management
  enable_ssm_access = true
}
```

## Integration with Meta-Roles

This module is designed to work with the meta-roles pattern. Meta-roles (creator, manager, reader) can assume these resource-specific roles to perform operations on EC2 resources.

Example trust relationship:

```hcl
# In your environment configuration
module "meta_roles" {
  source = "../../modules/iam/meta-roles"
  # ... other parameters
}

module "ec2_resource_roles" {
  source = "../../modules/iam/resource-roles/ec2"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  # ... other parameters
}
```

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |
| account_id | AWS account ID where the roles will be created | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for naming resources | `string` | `"resource"` | no |
| trusted_role_arns | List of ARNs of IAM roles that can assume these roles | `list(string)` | `[]` | no |
| enable_ssm_access | Whether to enable SSM access for EC2 instances | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| ec2_creator_role_arn | ARN of the EC2 creator role |
| ec2_creator_role_name | Name of the EC2 creator role |
| ec2_manager_role_arn | ARN of the EC2 manager role |
| ec2_manager_role_name | Name of the EC2 manager role |
| ec2_reader_role_arn | ARN of the EC2 reader role |
| ec2_reader_role_name | Name of the EC2 reader role |
| ec2_creator_policy_arn | ARN of the EC2 creator policy |
| ec2_manager_policy_arn | ARN of the EC2 manager policy |
| ec2_reader_policy_arn | ARN of the EC2 reader policy |
| ec2_ssm_access_policy_arn | ARN of the EC2 SSM access policy (if enabled) |