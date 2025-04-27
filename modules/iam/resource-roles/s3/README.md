# S3 Resource Roles Module

This module creates IAM roles and policies specifically for managing AWS S3 storage resources. It implements a role-based access control pattern with three levels of access:

1. **Creator Role**: Full permissions to create buckets and manage bucket configuration
2. **Manager Role**: Permissions to manage objects and bucket settings, but not create or delete buckets
3. **Reader Role**: Read-only access to buckets and objects

The module provides optional support for:
- Restricting access to specific S3 buckets
- Kubernetes etcd backup permissions

## Features

- Separate roles for creating, managing, and reading S3 resources
- Fine-grained IAM policies for each role
- Option to restrict access to specific S3 buckets
- Specialized permissions for Kubernetes etcd backups
- Support for versioning, encryption, and other S3 bucket features

## Usage

### Basic Usage

```hcl
module "s3_resource_roles" {
  source = "../../modules/iam/resource-roles/s3"

  name_prefix       = "k8s"
  environment       = "dev"
  
  # Roles that can assume these S3 resource roles
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
}
```

### Restricting to Specific Buckets

```hcl
module "s3_resource_roles" {
  source = "../../modules/iam/resource-roles/s3"

  name_prefix       = "k8s"
  environment       = "dev"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Limit access to specific buckets
  specific_bucket_arns = [
    "arn:aws:s3:::my-cluster-logs",
    "arn:aws:s3:::my-cluster-backups"
  ]
}
```

### Enabling Kubernetes etcd Backup Support

```hcl
module "s3_resource_roles" {
  source = "../../modules/iam/resource-roles/s3"

  name_prefix       = "k8s"
  environment       = "dev"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  
  # Enable etcd backup permissions
  enable_kubernetes_etcd_backup = true
  etcd_backup_bucket_arn        = "arn:aws:s3:::my-cluster-etcd-backups"
}
```

## Integration with Meta-Roles

This module is designed to work with the meta-roles pattern. Meta-roles (creator, manager, reader) can assume these resource-specific roles to perform operations on S3 resources.

Example trust relationship:

```hcl
# In your environment configuration
module "meta_roles" {
  source = "../../modules/iam/meta-roles"
  # ... other parameters
}

module "s3_resource_roles" {
  source = "../../modules/iam/resource-roles/s3"
  
  trusted_role_arns = [
    module.meta_roles.infrastructure_creator_role_arn,
    module.meta_roles.infrastructure_manager_role_arn
  ]
  # ... other parameters
}
```

## Kubernetes etcd Backup Support

When `enable_kubernetes_etcd_backup` is set to `true`, this module includes additional permissions specifically for backing up Kubernetes etcd data to S3. This is a critical operation for disaster recovery of a Kubernetes cluster.

The permissions allow:
- Uploading etcd snapshot files to S3
- Retrieving etcd snapshot files from S3
- Listing available backups
- Deleting old backups

## Required Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| environment | Environment name (e.g., dev, staging, prod) | `string` | n/a | yes |

## Optional Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name_prefix | Prefix for naming resources | `string` | `"resource"` | no |
| trusted_role_arns | List of ARNs of IAM roles that can assume these roles | `list(string)` | `[]` | no |
| specific_bucket_arns | List of specific S3 bucket ARNs to restrict access to | `list(string)` | `[]` | no |
| enable_kubernetes_etcd_backup | Whether to enable etcd backup permissions | `bool` | `false` | no |
| etcd_backup_bucket_arn | ARN of the S3 bucket for etcd backups | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| s3_creator_role_arn | ARN of the S3 creator role |
| s3_creator_role_name | Name of the S3 creator role |
| s3_manager_role_arn | ARN of the S3 manager role |
| s3_manager_role_name | Name of the S3 manager role |
| s3_reader_role_arn | ARN of the S3 reader role |
| s3_reader_role_name | Name of the S3 reader role |
| s3_creator_policy_arn | ARN of the S3 creator policy |
| s3_manager_policy_arn | ARN of the S3 manager policy |
| s3_reader_policy_arn | ARN of the S3 reader policy |
| kubernetes_etcd_backup_policy_arn | ARN of the Kubernetes etcd backup policy (if enabled) |