#!/bin/bash
# Kubernetes worker initialization script

CLUSTER_NAME="${cluster_name}"
LOG_FILE="/var/log/k8s-worker-init.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "==================== Kubernetes Worker Initialization ===================="
echo "Starting worker initialization at $(date)"
echo "Cluster: $CLUSTER_NAME"

# Install prerequisites (similar to master script)
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release jq

# Configure networking
echo 1 > /proc/sys/net/ipv4/ip_forward
modprobe br_netfilter
modprobe overlay

# Install containerd
apt-get install -y containerd
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
systemctl enable containerd
systemctl restart containerd

# Disable swap
swapoff -a
sed -i '/swap/d' /etc/fstab

# Install Kubernetes components
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubelet kubeadm kubectl
systemctl enable kubelet

# Fetch join information and join cluster
echo "Fetching cluster join information..."
if aws s3 cp s3://tfaws-dev-secrets/clusters/$CLUSTER_NAME/join-info.json /tmp/join-info.json; then
    TOKEN=$(jq -r '.token' /tmp/join-info.json)
    HASH=$(jq -r '.ca_cert_hash' /tmp/join-info.json)
    ENDPOINT=$(jq -r '.master_endpoint' /tmp/join-info.json)
    
    echo "Joining cluster at $ENDPOINT..."
    if kubeadm join $ENDPOINT --token $TOKEN --discovery-token-ca-cert-hash $HASH; then
        echo "Successfully joined cluster"
        echo "$(date)" > /var/log/k8s-worker-join-success
    else
        echo "FATAL: Failed to join cluster"
        shutdown -h now
    fi
    
    rm /tmp/join-info.json
else
    echo "FATAL: Could not fetch join information from S3"
    shutdown -h now
fi

echo "Worker initialization completed at $(date)"