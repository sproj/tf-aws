#!/bin/bash
# Minimal master runtime script for custom AMI
# All packages are pre-installed, just do master-specific setup

CLUSTER_NAME="${cluster_name}"
POD_NETWORK_CIDR="${pod_network_cidr}"
SERVICE_CIDR="${service_cidr}"
PRIVATE_IP=$(hostname -I | awk '{print $1}')

LOG_FILE="/var/log/k8s-master-runtime.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "==================== K8s Master Runtime Init ===================="
echo "Starting master runtime initialization at $(date)"
echo "Cluster: $CLUSTER_NAME"
echo "Pod CIDR: $POD_NETWORK_CIDR"
echo "Service CIDR: $SERVICE_CIDR"
echo "Private IP: $PRIVATE_IP"

# Apply sysctl settings (in case they weren't persisted)
sysctl --system

# Start containerd
systemctl start containerd

# Initialize Kubernetes cluster
echo "Initializing Kubernetes cluster..."
kubeadm init \
  --pod-network-cidr=$POD_NETWORK_CIDR \
  --service-cidr=$SERVICE_CIDR

if [ $? -ne 0 ]; then
    echo "ERROR: kubeadm init failed"
    exit 1
fi

# Setup kubectl for ubuntu user
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube

# Add tls-server-name to kubeconfig
sed -i "/server: https/a\\    tls-server-name: $PRIVATE_IP" /home/ubuntu/.kube/config

# Install Flannel
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"

# Allow scheduling on control plane (for single-node testing)
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true

# Generate and store join information
echo "Generating join information for workers..."
BOOTSTRAP_TOKEN=$(kubeadm token create --ttl 24h0m0s)
CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
               openssl rsa -pubin -outform der 2>/dev/null | \
               openssl dgst -sha256 -hex | sed 's/^.* //')

cat > /tmp/cluster-join-info.json << EOF
{
  "token": "$BOOTSTRAP_TOKEN",
  "ca_cert_hash": "sha256:$CA_CERT_HASH", 
  "master_endpoint": "$PRIVATE_IP:6443",
  "generated_at": "$(date -Iseconds)",
  "expires_at": "$(date -d '+24 hours' -Iseconds)"
}
EOF

# Upload to S3
aws s3 cp /tmp/cluster-join-info.json \
  s3://tfaws-dev-secrets/clusters/$CLUSTER_NAME/join-info.json \
  --server-side-encryption AES256

if [ $? -eq 0 ]; then
    echo "Join information stored successfully"
else
    echo "WARNING: Failed to store join information to S3"
fi

rm /tmp/cluster-join-info.json

echo "Master runtime initialization completed at $(date)"
echo "$(date)" > /var/log/k8s-master-runtime-complete