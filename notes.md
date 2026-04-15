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
Once the cluster is reachable via SSH tunnel to master private IP, apply components in this order:

#### External Secrets Operator
```
kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/eso/external-secrets.namespace.yaml

kubectl create secret generic eso-reader-aws-credentials \
  --namespace external-secrets \
  --from-literal=access-key-id=$(aws ssm get-parameter --name /dev/dev-k8s/eso-reader-ssm-access-key-id --with-decryption --query Parameter.Value --output text --profile super-user) \
  --from-literal=secret-access-key=$(aws ssm get-parameter --name /dev/dev-k8s/eso-reader-ssm-secret-access-key --with-decryption --query Parameter.Value --output text --profile super-user)

helm install external-secrets external-secrets/external-secrets --namespace external-secrets

kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/eso/cluster-secret-store.yaml
```

#### EBS CSI Driver
```
kubectl create secret generic aws-secret \
  --namespace kube-system \
  --from-literal=key_id=$(aws ssm get-parameter --name /dev/dev-k8s/ebs-csi-ec2-access-key-id --with-decryption --query Parameter.Value --output text --profile super-user) \
  --from-literal=access_key=$(aws ssm get-parameter --name /dev/dev-k8s/ebs-csi-ec2-secret-access-key --with-decryption --query Parameter.Value --output text --profile super-user)

helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver

helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver \
  --namespace kube-system \
  -f examples/dev-kubernetes-ec2/layered/control_plane/ebs-csi/ebs-csi-values.yaml

kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/ebs-csi/storageclass.yaml
```

#### Block IMDS (pod-level)
```
kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/block-imds.yaml
```

#### cert-manager
```
helm repo add jetstack https://charts.jetstack.io

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/cert-manager/cert-manager-external-secrets.yaml
kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/cert-manager/cluster-issuer.yaml
```

#### AWS Load Balancer Controller
```
kubectl apply -f examples/dev-kubernetes-ec2/layered/control_plane/aws-lbc/aws-lbc-external-secrets.yaml

helm repo add eks https://aws.github.io/eks-charts

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace kube-system \
  -f examples/dev-kubernetes-ec2/layered/control_plane/aws-lbc/aws-lbc-values.yaml
```

#### ingress-nginx
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  -f examples/dev-kubernetes-ec2/layered/control_plane/ingress-nginx/ingress-nginx-values.yaml
```

#### DNS records (one-time only)
```
cd bootstrap/dns-records/ && terraform apply
```
This creates the Route53 ALIAS record pointing jonesalan404.dev at the NLB. Only needed once, but must be re-applied if the NLB DNS name changes (see known limitations below).

### Every restart: patch providerID on nodes
LBC requires a `providerID` on each node to register EC2 instances as NLB targets. This must be done manually after every cluster restart (nodes get new IPs and instance IDs via DHCP/autoscaling).

1. Discover current nodes and IPs:
   ```
   kubectl get nodes -o wide
   ```

2. Resolve instance IDs and AZs for each node IP:
   ```
   aws ec2 describe-instances \
     --filters "Name=private-ip-address,Values=<ip>" \
     --query 'Reservations[].Instances[].[PrivateIpAddress,InstanceId,Placement.AvailabilityZone]' \
     --output table \
     --profile kubernetes-ec2-creator --region eu-west-1
   ```

3. Patch each node:
   ```
   kubectl patch node <node-name> -p '{"spec":{"providerID":"aws:///<az>/<instance-id>"}}'
   ```

4. Restart LBC to force reconciliation:
   ```
   kubectl rollout restart deployment aws-load-balancer-controller -n kube-system
   ```

## Tearing down the cluster

Destroy in reverse order:

```
cd worker_nodes/        && terraform destroy
cd control_plane/       && terraform destroy
cd base_infrastructure/ && terraform destroy
```

Note: Parameter Store secrets and the `bootstrap/dns-records` Route53 record are not managed by the cluster Terraform layers and will persist after destroy.

## Known manual steps / limitations
- **providerID** must be patched on every cluster restart (see above). Should eventually be automated in node startup scripts by querying IMDS for instance-id and AZ and passing `--provider-id` to kubelet.
- **NLB DNS name** changes on each cluster recreation. Must update `bootstrap/dns-records` with the new `nlb_dns_name` and re-apply.
- **Jaeger subpath** — Jaeger UI breaks at `/jaeger` because it expects to be served from `/`. Needs a separate subdomain (e.g. `jaeger.jonesalan404.dev`) or a rewrite annotation on its Ingress.
- Region is hardcoded to eu-west-1 throughout.
- SSM policy scoped to `/dev/dev-k8s/*` — update if path convention changes.
