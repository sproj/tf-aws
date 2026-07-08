# tf-aws

A learning project for building AWS infrastructure with Terraform, capped by a
self-managed Kubernetes cluster on EC2. The repo is organized as a small
platform: reusable modules for IAM/networking/compute, deployment-type
wrappers that wire those modules together, and a layered example that stands
up a real dev cluster with ingress, secrets management, and a few shared
in-cluster services (Postgres, RabbitMQ, Redis, Jaeger, Prometheus).

See [CLAUDE.md](CLAUDE.md) for the detailed architecture reference (module
layers, IAM role hierarchy, state backend naming) and command syntax. See
[notes.md](notes.md) for the operational runbook — the actual order of
`terraform apply`s to stand up and tear down the dev cluster, plus known
tech debt and manual steps.

## Layout

```
bootstrap/            One-time/rarely-changed setup: state backend, meta-roles,
                       secrets backend, DNS zone, and per-service credentials
                       (Postgres, RabbitMQ, Redis, cert-manager, ESO, AWS LBC).

modules/
  permissions/         IAM action lists per AWS service (networking, ec2, iam,
                        ecr, autoscaling, elasticloadbalancing, route53, s3, ssm),
                        split into creator/manager/reader tiers.
  infrastructure/       Reusable infra building blocks (networking, ec2-instance,
                        autoscaling-group, security-groups, iam-instance-profile,
                        ebs-csi-policy, ssm-policies).
  deployment-types/     Wires infrastructure modules into a deployable unit:
                        kubernetes-ec2, ec2-app, fargate.
  iam/                  IAM roles for operating a deployment type, and for
                        applications running on top of it.

examples/
  dev-kubernetes-ec2/
    layered/            The preferred, production-like pattern: each layer
                        (base_infrastructure, control_plane, worker_nodes,
                        cluster_operators, cluster_ingress, cluster/, dns_records)
                        is its own Terraform root with its own state, wired
                        together via terraform_remote_state.

applications/          Kubernetes manifests for workloads deployed to the cluster.

packer/                Builds the Ubuntu 22.04 + containerd + kubeadm AMI used
                       by the EC2 nodes.

docs/learning/         Notes written while learning Kubernetes/Terraform concepts
                       (gitignored — local only).

check-k8s-init.sh       Tail kubeadm init logs from the control-plane node.
merge_kubeconfig.sh     Merge the cluster's kubeconfig into ~/.kube/config.
start-k8s-tunnel.sh     SSH tunnel to reach the API server through a bastion.
```

## Getting started

1. Configure AWS profiles: `super-user`, `infrastructure-manager`,
   `kubernetes-ec2-creator` (see [CLAUDE.md](CLAUDE.md#aws-profiles-local-awscredentials)).
2. Apply the bootstrap sequence once, in order — see
   [CLAUDE.md](CLAUDE.md#bootstrap-sequence-apply-once-in-order).
3. Build the node AMI with Packer.
4. Follow the layer-by-layer apply order in [notes.md](notes.md) to stand up
   the dev cluster.

All examples target the `eu-west-1` region.
