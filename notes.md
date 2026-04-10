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
```

### Post-apply: apply manifests to the cluster
Once the cluster is reachable (via SSH tunnel to master private IP):

```
kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/storageclass.yaml
kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/block-imds.yaml
kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/cluster-secret-store.yaml
```

## Tearing down the cluster

Destroy in reverse order:

```
cd worker_nodes/        && terraform destroy
cd control_plane/       && terraform destroy
cd base_infrastructure/ && terraform destroy
```

Note: Parameter Store secrets are not managed by Terraform and will persist after destroy.

## Known manual steps / limitations
- Cluster is only reachable via SSH tunnel (no public ingress yet)
- Region is hardcoded to eu-west-1 throughout
- SSM policy scoped to `/dev/dev-k8s/*` — update if path convention changes
