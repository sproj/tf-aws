#!/bin/bash
# Kubernetes master initialization script

# Script variables (inserted by Terraform)
POD_NETWORK_CIDR="${pod_network_cidr}"
SERVICE_CIDR="${service_cidr}"
KUBERNETES_VERSION="${kubernetes_version}"
CNI_VERSION="${cni_version}"
PRIVATE_IP="${private_ip}"

# Setup logging to multiple outputs
# This creates a log file but also shows output in cloud-init logs
LOG_FILE="/var/log/k8s-master-init.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "==================== Kubernetes Master Initialization ===================="
echo "Starting initialization at $(date)"
echo "Pod CIDR: $POD_NETWORK_CIDR"
echo "Service CIDR: $SERVICE_CIDR"
echo "Kubernetes Version: $KUBERNETES_VERSION"
echo "Private IP: $PRIVATE_IP"
echo "======================================================================"

# Function to log steps with timestamps
log_step() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Function to mark start and end of major sections
start_section() {
    echo ""
    echo "--------------------------------------------------------------------"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] STARTING: $1"
    echo "--------------------------------------------------------------------"
}

end_section() {
    echo "--------------------------------------------------------------------"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] COMPLETED: $1"
    echo "--------------------------------------------------------------------"
    echo ""
}

# System preparation
start_section "System Preparation"
log_step "Updating package lists"
apt-get update

log_step "Installing prerequisites"
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release jq

log_step "Configuring network settings"
echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

# Set up some network level dark magic for flannel
log_step "Loading required kernel modules"
modprobe br_netfilter
modprobe overlay

log_step "Configuring kernel parameters for Kubernetes"
cat > /etc/sysctl.d/k8s.conf << EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system
end_section "System Preparation"

# Container runtime installation
start_section "Container Runtime Installation"
log_step "Installing containerd"
apt-get install -y containerd

log_step "Configuring containerd"
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

log_step "Starting containerd service"
systemctl enable containerd
systemctl restart containerd
end_section "Container Runtime Installation"

# Kubernetes components installation
start_section "Kubernetes Installation"
log_step "Disabling swap (required for Kubernetes)"
swapoff -a
sed -i '/swap/d' /etc/fstab

log_step "Adding Kubernetes apt repository"
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v$KUBERNETES_VERSION/deb/ /" > /etc/apt/sources.list.d/kubernetes.list

log_step "Installing kubelet, kubeadm and kubectl"
apt-get update
apt-get install -y kubelet kubeadm kubectl
systemctl enable kubelet
end_section "Kubernetes Installation"

# Initialize Kubernetes
start_section "Kubernetes Cluster Initialization"
log_step "Initializing Kubernetes cluster with kubeadm"
kubeadm init --pod-network-cidr=$POD_NETWORK_CIDR --service-cidr=$SERVICE_CIDR

if [ $? -ne 0 ]; then
    log_step "ERROR: kubeadm init failed. Check logs for details."
    exit 1
fi
end_section "Kubernetes Cluster Initialization"

# Setup kubectl for the ubuntu user
start_section "Configuring kubectl"
log_step "Setting up kubeconfig for ubuntu user"
mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config

log_step "Adding tls-server-name to kubeconfig"

# Get the private IP
PRIVATE_IP=$(hostname -I | awk '{print $1}')

# Backup the original config
cp /home/ubuntu/.kube/config /home/ubuntu/.kube/config.backup

# Use sed to add the tls-server-name line after the server line
# This assumes a standard kubeconfig structure
sed -i "/server: https/a\\    tls-server-name: $PRIVATE_IP" /home/ubuntu/.kube/config

log_step "Kubeconfig updated with tls-server-name setting"

# Fix permissions
chown -R ubuntu:ubuntu /home/ubuntu/.kube
end_section "Configuring kubectl"

# Install network plugin (Flannel)
start_section "Network Plugin Installation"
export KUBECONFIG=/etc/kubernetes/admin.conf

# Try to use the latest version from GitHub first
log_step "Attempting to apply latest Flannel manifest from GitHub..."
if kubectl apply -f "https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml"; then
  log_step "Successfully applied latest Flannel manifest from GitHub"
else
  # Fall back to the local copy
  log_step "Failed to apply manifest from GitHub, falling back to local copy (v$CNI_VERSION)"
  
  # Create a directory for the manifest
  mkdir -p /opt/kubernetes/manifests
  
  # Create the local manifest file using the provided content
  cat > /opt/kubernetes/manifests/kube-flannel.yml << EOF
${flannel_manifest}
EOF
  
  # Apply the local manifest
  kubectl apply -f /opt/kubernetes/manifests/kube-flannel.yml
fi
# Allow scheduling on control plane node (for single-node clusters)
log_step "Allowing pods on control-plane node"
kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
end_section "Network Plugin Installation"

# Verify cluster is ready
start_section "Cluster Verification"
log_step "Waiting for node to become ready"
attempt=0
max_attempts=10
until kubectl get nodes | grep -q "Ready"; do
    attempt=$((attempt+1))
    if [ $attempt -ge $max_attempts ]; then
        log_step "WARNING: Node not ready after $max_attempts attempts. Continuing anyway."
        break
    fi
    log_step "Attempt $attempt/$max_attempts: Node not ready yet. Waiting 30 seconds..."
    sleep 30
done

if kubectl get nodes | grep -q "Ready"; then
    log_step "SUCCESS: Node is now in Ready state."
    kubectl get nodes
else
    log_step "WARNING: Node may not be ready. Check 'kubectl get nodes' output:"
    kubectl get nodes
fi

# Display pod status
log_step "Current pod status:"
kubectl get pods --all-namespaces
end_section "Cluster Verification"

echo "========================================================================"
echo "Kubernetes master initialization completed at $(date)"
echo "Check $LOG_FILE for detailed logs"
echo "========================================================================"

echo "========================================================================"
echo "Storing cluster join information for workers..."

# Generate join command components
BOOTSTRAP_TOKEN=$(kubeadm token create --ttl 24h0m0s)
CA_CERT_HASH=$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | \
               openssl rsa -pubin -outform der 2>/dev/null | \
               openssl dgst -sha256 -hex | sed 's/^.* //')
MASTER_ENDPOINT="${private_ip}:6443"

# Create join info JSON
cat > /tmp/cluster-join-info.json << EOF
{
  "token": "$BOOTSTRAP_TOKEN",
  "ca_cert_hash": "sha256:$CA_CERT_HASH", 
  "master_endpoint": "$MASTER_ENDPOINT",
  "generated_at": "$(date -Iseconds)",
  "expires_at": "$(date -d '+24 hours' -Iseconds)"
}
EOF

# Upload to S3
aws s3 cp /tmp/cluster-join-info.json \
  s3://tfaws-dev-secrets/clusters/${cluster_name}/join-info.json \
  --server-side-encryption AES256

if [ $? -eq 0 ]; then
    echo "Join information stored successfully"
else
    echo "WARNING: Failed to store join information to S3"
fi

rm /tmp/cluster-join-info.json
echo "========================================================================"

# Write a "done" marker file that can be checked to verify completion
echo "$(date)" > /var/log/k8s-master-init.done