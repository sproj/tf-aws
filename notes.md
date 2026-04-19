# Cluster Operations

## Standing up the cluster

### Prerequisites (one-time)
- AWS profiles configured: `super-user`, `infrastructure-manager`, `kubernetes-ec2-creator`
- Packer AMI built and `ami_id` set in control_plane and worker_nodes tfvars
- Parameter Store secrets populated manually under `/dev/dev-k8s/<application>/<secret-name>`
  (these are long-lived and only need updating if credentials rotate)

### Terraform layers (apply in order)
Each layer is applied from its directory under `examples/dev-kubernetes-ec2/layered/`.

```
cd base_infrastructure/ && terraform apply
cd control_plane/       && terraform apply
cd worker_nodes/        && terraform apply
cd helm_operators/      && terraform apply
```

`helm_operators` installs all cluster operators (ESO, EBS CSI, block-imds, cert-manager, AWS LBC, ingress-nginx) via the Helm and Kubernetes Terraform providers. It connects to the cluster API using TLS credentials written to SSM by `master-runtime.sh` at cluster init time.

**First apply on a fresh cluster requires two passes** — see Known manual steps below.

#### DNS records (one-time only)
```
cd bootstrap/dns-records/ && terraform apply
```
This creates the Route53 ALIAS record pointing jonesalan404.dev at the NLB. Only needed once, but must be re-applied if the NLB DNS name changes (see known limitations below).

## Tearing down the cluster

Destroy in reverse order:

```
cd worker_nodes/        && terraform destroy
cd control_plane/       && terraform destroy
cd base_infrastructure/ && terraform destroy
```

Note: Parameter Store secrets and the `bootstrap/dns-records` Route53 record are not managed by the cluster Terraform layers and will persist after destroy.

## Known tech debt / cleanup items
- **Some helm charts require direct URLs** — Terraform's helm provider (v2.17.0) fails with "Chart.yaml file is missing" for any Helm repo whose `index.yaml` stores charts on an external backend (e.g. GitHub releases) rather than directly on the repo server. Affected charts so far: cert-manager (`https://charts.jetstack.io/charts/cert-manager-vX.Y.Z.tgz`) and ingress-nginx (`https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-X.Y.Z/ingress-nginx-X.Y.Z.tgz`). Workaround: omit `repository` and `version`, set `chart` to the direct tgz URL. To find the URL: `curl -s <repo-index-url>/index.yaml` and look for the `urls:` field for the desired chart version. Update URLs when upgrading.
- **`master-runtime.sh` hardcodes env and cluster name** — SSM parameter paths (`/dev/dev-k8s/k8s-api/...`) and the S3 bucket name (`tfaws-dev-secrets`) are hardcoded strings rather than using `$CLUSTER_NAME` or template variables injected by Terraform, unlike the `${cluster_name}` pattern used elsewhere in the same script.

## Known manual steps / limitations
- **helm_operators first apply requires two passes** — `kubernetes_manifest` resources for CRD-backed types (ClusterSecretStore, ClusterIssuer, etc.) fail at plan time on a fresh cluster because the CRDs don't exist until the operator Helm charts are applied. Workaround:
  ```bash
  terraform apply -target=helm_release.external_secrets -target=helm_release.cert_manager_chart  # install operators first
  terraform apply                                                                             # then apply CRD-backed manifests
  ```
- **NLB DNS name** changes on each cluster recreation. Must update `bootstrap/dns-records` with the new `nlb_dns_name` and re-apply.
- **Jaeger subpath** — Jaeger UI breaks at `/jaeger` because it expects to be served from `/`. Needs a separate subdomain (e.g. `jaeger.jonesalan404.dev`) or a rewrite annotation on its Ingress.
- Region is hardcoded to eu-west-1 throughout.
- SSM policy scoped to `/dev/dev-k8s/*` — update if path convention changes.
