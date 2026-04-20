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
cd base_infrastructure/     && terraform apply
cd control_plane/           && terraform apply
cd worker_nodes/            && terraform apply
cd cluster_operators/       && terraform apply
cd cluster_workload/        && terraform apply
cd cluster_observability/   && terraform apply
```

`cluster_operators` installs ESO and cert-manager via Helm. These create the CRDs required by `cluster_workload`.

`cluster_workload` installs EBS CSI, AWS LBC, and ingress-nginx via Helm, then applies all CRD-backed manifests (ClusterSecretStore, ExternalSecrets, ClusterIssuer, block-imds).

`cluster_observability` creates the `observability` namespace and deploys a shared Jaeger instance. Applications send traces to `http://jaeger.observability.svc.cluster.local:4317`. Access the UI via `kubectl port-forward svc/jaeger 16686:16686 -n observability`.

#### DNS record
```
# Wait for the NLB to reach active state (~2-3 minutes after cluster_workload completes)
cd dns_records/ && terraform apply
```
This reads the NLB hostname dynamically from the ingress-nginx service and creates the Route53 ALIAS record pointing jonesalan404.dev at it. Must be re-applied on each cluster rebuild (the NLB hostname changes each time).

## Tearing down the cluster

Destroy in reverse order:

```
cd worker_nodes/        && terraform destroy
cd control_plane/       && terraform destroy
cd base_infrastructure/ && terraform destroy
```

Note: Parameter Store secrets persist after destroy. The `dns_records` Route53 record is managed by the cluster layers and should be destroyed before tearing down the cluster if you want a clean state, or simply re-applied after the next rebuild.

## Known tech debt / cleanup items
- **Some helm charts require direct URLs** — Terraform's helm provider (v2.17.0) fails with "Chart.yaml file is missing" for any Helm repo whose `index.yaml` stores charts on an external backend (e.g. GitHub releases) rather than directly on the repo server. Affected charts so far: cert-manager (`https://charts.jetstack.io/charts/cert-manager-vX.Y.Z.tgz`) and ingress-nginx (`https://github.com/kubernetes/ingress-nginx/releases/download/helm-chart-X.Y.Z/ingress-nginx-X.Y.Z.tgz`). Workaround: omit `repository` and `version`, set `chart` to the direct tgz URL. To find the URL: `curl -s <repo-index-url>/index.yaml` and look for the `urls:` field for the desired chart version. Update URLs when upgrading.
- **`master-runtime.sh` hardcodes env and cluster name** — SSM parameter paths (`/dev/dev-k8s/k8s-api/...`) and the S3 bucket name (`tfaws-dev-secrets`) are hardcoded strings rather than using `$CLUSTER_NAME` or template variables injected by Terraform, unlike the `${cluster_name}` pattern used elsewhere in the same script.

## Known manual steps / limitations
- **Wait before applying `dns_records`** — the NLB takes 2-3 minutes to reach active state after `cluster_workload` completes. Applying `dns_records` too early will read an empty hostname from the ingress-nginx service.
- **Jaeger UI access** — currently via `kubectl port-forward` only. Adding an Ingress with subdomain `jaeger.jonesalan404.dev` is a future task (subpath routing breaks the UI).
- Region is hardcoded to eu-west-1 throughout.
- SSM policy scoped to `/dev/dev-k8s/*` — update if path convention changes.
