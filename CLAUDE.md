# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

### Terraform
All Terraform commands are run from within the specific module or example directory.

```bash
terraform init
terraform plan -var-file="<name>.tfvars"   # or auto.tfvars are picked up automatically
terraform apply
terraform destroy
```

### Packer (build Kubernetes AMI)
```bash
cd packer/
./build-ami.sh          # validates, builds, and cleans up old AMIs
packer init k8s-base.pkr.hcl
packer validate -var-file="ubuntu-22-k8s.pkrvars.hcl" k8s-base.pkr.hcl
packer build -var-file="ubuntu-22-k8s.pkrvars.hcl" k8s-base.pkr.hcl
```

## Architecture

### Bootstrap sequence (apply once, in order)
1. **`bootstrap/state-backend/`** — creates the S3 bucket (`tfaws-dev-state-backend`) and DynamoDB table (`tfaws-dev-lock-backend`) for remote state. Uses `super-user` AWS profile. Applied once and rarely changed.
2. **`bootstrap/meta-roles/`** — creates the `infrastructure-manager` IAM role (scoped to IAM actions). Reads state-backend outputs via `terraform_remote_state`.
3. **`bootstrap/secrets-backend/`** — creates an encrypted S3 bucket used by Kubernetes nodes for the kubeadm join command.

### IAM role hierarchy
Roles follow a **creator / manager / reader** pattern at two levels:

- **Meta-roles** (`bootstrap/meta-roles/`): bootstrap-level roles for managing infrastructure via Terraform (currently `infrastructure-manager`).
- **Deployment-type roles** (`modules/iam/deployment-type-roles/<type>/`): scoped roles per deployment type. For `kubernetes-ec2`, these are `kubernetes-ec2-creator`, `kubernetes-ec2-manager`, `kubernetes-ec2-reader`.

Permission sets are defined as locals in `modules/permissions/<service>/locals.tf` (networking, ec2, iam, ecr, autoscaling, elasticloadbalancing). Each service exposes `creator_permissions`, `manager_permissions`, and `reader_permissions` lists. These are concatenated in the deployment-type roles module to build the final IAM policy.

### Module layers
```
modules/
  permissions/<service>/      # IAM action lists per service, per role level
  infrastructure/<resource>/  # Reusable infra resources (networking, ec2-instance, autoscaling-group, security-groups, iam-instance-profile)
  deployment-types/<type>/    # Wires together infrastructure modules for a deployment type
    kubernetes-ec2/
      base_infrastructure/    # VPC, subnets, security groups, IAM instance profile
      control_plane/          # Master node autoscaling group
      worker_nodes/           # Worker node autoscaling group
  iam/
    deployment-type-roles/<type>/  # IAM roles for operating a deployment type
    application-roles/             # IAM roles for applications running on infrastructure
```

### Examples (layered vs simple)
`examples/dev-kubernetes-ec2/` provides two patterns:
- **`simple/`**: single Terraform root applying all layers at once.
- **`layered/`**: three separate Terraform roots (`base_infrastructure/`, `control_plane/`, `worker_nodes/`) with separate S3 state keys. Layers communicate via `terraform_remote_state` data sources. This is the preferred pattern for production-like setups.

All examples use the `kubernetes-ec2-creator` AWS profile and `eu-west-1` region.

### Packer
`packer/k8s-base.pkr.hcl` builds an Ubuntu 22.04 AMI with containerd, kubeadm, kubelet, and kubectl pre-installed (Kubernetes 1.33 by default). The AMI is used as `node_ami_id` in the Terraform examples. Build requires an existing VPC/subnet (specified in `ubuntu-22-k8s.pkrvars.hcl`).

### State backend naming
- S3 bucket: `tfaws-{env}-state-backend`
- DynamoDB table: `tfaws-{env}-lock-backend`
- State keys follow the pattern: `bootstrap/terraform.tfstate`, `examples/kubernetes-ec2/<layer>/terraform.tfstate`

### AWS profiles (local `~/.aws/credentials`)
- `super-user` — used only for bootstrapping the state backend
- `infrastructure-manager` — used by meta-roles and deployment-type role modules
- `kubernetes-ec2-creator` — used by the layered example deployments
