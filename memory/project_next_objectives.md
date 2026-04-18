---
name: Next objectives
description: Current in-progress work and what comes next in the project
type: project
---

## In progress: helm_operators layer

Building `examples/dev-kubernetes-ec2/layered/helm_operators/` to replace all manual post-cluster steps with Terraform.

### Completed this session
- `modules/infrastructure/ssm-policies/` — added SSM write policy (PutParameter scoped to `/dev/dev-k8s/k8s-api/{cluster_ca_certificate,client_certificate,client_key}`)
- `examples/dev-kubernetes-ec2/layered/base_infrastructure/main.tf` — updated to attach ssm write policy to instance profile
- `master-runtime.sh` — writes k8s TLS credentials to SSM after kubeadm init
- `helm_operators/main.tf` — skeleton complete: backend, providers (aws/helm/kubernetes), remote state data source, SSM data sources for k8s certs, both providers configured with inline credentials
- `helm_operators/variables.tf` and `dev-k8s.auto.tfvars` created
- ESO: kubernetes_namespace and kubernetes_secret resources written and reviewed

### Next: continue helm_operators/main.tf in install order
1. **ESO** (in progress) — namespace ✓, credentials secret ✓, still need: `helm_release` for ESO, `kubernetes_manifest` for ClusterSecretStore
2. **EBS CSI** — credentials secret (bootstrap, same pattern as ESO), helm_release, storageclass manifest
3. **Block IMDS** — kubernetes_manifest
4. **cert-manager** — helm_release (with crds.enabled=true), ExternalSecret manifest, ClusterIssuer manifest
5. **AWS LBC** — ExternalSecret manifest, helm_release (with values file)
6. **ingress-nginx** — helm_release (with values file)

### Key design decisions made
- k8s TLS creds stored in SSM (written by master-runtime.sh), read by helm_operators via data sources
- host/tls_server_name come from control_plane remote state outputs (not SSM), since public IP changes on rebuild
- Helm and kubernetes providers both need identical connection config (separate plugin processes)
- Ordering enforced via implicit Terraform dependency references where possible, explicit depends_on where needed

**Why:** Eliminate all manual post-cluster steps so cluster is fully reproducible from terraform apply alone.

### End-of-day small task
- Set `TF_PLUGIN_CACHE_DIR=~/.terraform.d/plugin-cache` (e.g. in `~/.zshrc`) to eliminate repeated provider binary storage across roots.
