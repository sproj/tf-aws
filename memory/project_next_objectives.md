---
name: Next objectives
description: Current in-progress work and what comes next in the project
type: project
---

## Completed: helm_operators split into cluster_operators + cluster_workload

`helm_operators/` has been replaced by two layers:
- `cluster_operators/` — installs Helm charts only (ESO, cert-manager). Creates CRDs. No CRD-dependent manifests.
- `cluster_workload/` — applies everything else (EBS CSI, AWS LBC, ingress-nginx, ClusterSecretStore, ExternalSecrets, ClusterIssuer, block-imds).

Layer apply order: base_infrastructure → control_plane → worker_nodes → cluster_operators → cluster_workload.

The two-pass apply problem is eliminated: CRDs are guaranteed present by layer ordering.

## Completed: providerID automation

`master-runtime.sh` and `worker-runtime.sh` now query IMDS for instance-id and AZ at boot time and write `KUBELET_EXTRA_ARGS=--provider-id=aws:///<az>/<instance-id>` to `/etc/default/kubelet` before kubelet/kubeadm starts. No more manual patching after cluster restart.

## Future: IAM structure review

Currently three overlapping IAM mechanisms are in play:
1. IAM users created per application (e.g. eso-reader, ebs-csi, cert-manager, aws-lbc) with credentials stored in SSM
2. Node instance role with permissions attached (used by nodes at runtime)
3. `kubernetes-ec2-creator` assumed role with permissions (used by Terraform)

Suspicion: one or the other of (1) and (2) should suffice — the duplication may be unnecessary. Worth reviewing whether application credentials could be replaced entirely by instance role + IRSA-equivalent, or vice versa.

## Known manual steps / limitations (see notes.md for full detail)

- ~~**helm_operators first apply requires two passes**~~ — fixed by splitting into cluster_operators + cluster_workload layers.
- **NLB DNS name** changes on each cluster recreation; must re-apply `bootstrap/dns-records`.
- **Jaeger subpath** — Jaeger UI breaks at `/jaeger`; needs its own subdomain or rewrite annotation.

## Key design decisions

- k8s TLS creds stored in SSM (written by master-runtime.sh), read by helm_operators via data sources
- host/tls_server_name come from control_plane remote state outputs (not SSM)
- helm charts with externally-hosted tgz use direct URL in `chart` field (Terraform helm provider v2.17.0 bug workaround)
- providerID written to /etc/default/kubelet before kubeadm starts kubelet, so no restart needed
