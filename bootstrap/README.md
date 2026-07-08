# bootstrap/

One-time or rarely-changed setup that everything else depends on. All state
lives in the `bootstrap/*` key prefix of the shared state backend
(`tfaws-dev-state-backend`).

## Apply once, in dependency order

| Dir | Creates | Profile |
|---|---|---|
| `state-backend/` | The S3 bucket + DynamoDB table that hold all Terraform state (including its own — bootstrapped with a local state file first). | `super-user` |
| `meta-roles/` | The `infrastructure-manager` IAM role used to apply everything below it and the deployment-type role modules. | `super-user` |
| `secrets-backend/` | Encrypted S3 bucket nodes write the kubeadm join command to at boot. | `infrastructure-manager` |
| `dns/` | The Route53 hosted zone for `jonesalan404.dev`. Applied once; nameservers are then set at the registrar (see `nameservers_notes.tfstate`). | `infrastructure-manager` |

## Per-service IAM users + SSM credentials

Each of these creates an IAM user scoped to one AWS-facing Kubernetes
controller, an access key, and writes both to SSM Parameter Store under
`/dev/dev-k8s/<service>/...` for External Secrets Operator to sync into the
cluster. They're long-lived — only re-apply if a key needs rotating.

- `aws-lbc-credentials/` — AWS Load Balancer Controller
- `cert-manager-credentials/` — cert-manager (Route53 DNS-01 solver; reads the zone ID from `dns/`'s state)
- `ebs-csi-credentials/` — EBS CSI driver
- `eso-credentials/` — External Secrets Operator's own SSM reader

## In-cluster datastore credentials

These don't touch IAM — they generate a random password with the `random`
provider and write superuser credentials to SSM for the in-cluster
Postgres/RabbitMQ/Redis instances (deployed by
`examples/dev-kubernetes-ec2/layered/cluster/`) to pick up:

- `postgres-credentials/`
- `rabbit-mq-credentials/`
- `redis-credentials/`

## Known stale code

- **`dns-records/` looks unused.** It creates the same Route53 ALIAS record as
  `examples/dev-kubernetes-ec2/layered/dns_records/`, but takes the NLB
  hostname as a static variable instead of reading it live from the
  ingress-nginx Kubernetes service. The layered example's `dns_records/` is
  the one actually used per the runbook in [`../notes.md`](../notes.md) — this
  directory predates it and hasn't been deleted yet.
