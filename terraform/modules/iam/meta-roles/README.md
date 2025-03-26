# Meta Roles Module

This module creates high-level IAM roles used for managing infrastructure through Terraform.

## Purpose

These roles provide a hierarchy of access levels for different stages of infrastructure management:

1. **Creator Role**: Used during initial setup and resource creation phases
2. **Manager Role**: Used for ongoing management of existing resources
3. **Reader Role**: Provides read-only access for monitoring and auditing

## Development Note

During initial development, the Creator and Manager roles are intentionally given broad permissions via the PowerUserAccess policy. This approach facilitates development and testing without getting blocked by permission issues.

Once the resource-specific roles are tested and working properly, these meta-roles should be restricted to only the minimum required permissions following the principle of least privilege.

## Usage

```hcl
module "meta_roles" {
  source = "../../modules/iam/meta-roles"

  account_id           = "123456789012"
  environment          = "dev"
  trusted_principal_arns = [
    "arn:aws:iam::123456789012:user/developer"
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| account_id | The AWS account ID where the roles will be created | `string` | n/a | yes |
| environment | The environment where these roles will be used | `string` | n/a | yes |
| trusted_principal_arns | List of ARNs of IAM principals that can assume these roles | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| infrastructure_creator_role_arn | ARN of the infrastructure creator role |
| infrastructure_manager_role_arn | ARN of the infrastructure manager role |
| infrastructure_reader_role_arn | ARN of the infrastructure reader role |
| infrastructure_creator_role_name | Name of the infrastructure creator role |
| infrastructure_manager_role_name | Name of the infrastructure manager role |
| infrastructure_reader_role_name | Name of the infrastructure reader role |