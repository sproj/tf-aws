#!/bin/bash
# Minimal worker runtime script for custom AMI
# All packages are pre-installed, just join the cluster

CLUSTER_NAME="${cluster_name}"

LOG_FILE="/var/log/k8s-worker-runtime.log"
exec > >(tee -a $LOG_FILE) 2>&1

echo "==================== K8s Worker Runtime Init ===================="
echo "Starting worker runtime initialization at $(date)"
echo "Cluster: $CLUSTER_NAME"

# Apply sysctl settings
sysctl --system

# Start containerd and kubelet
systemctl start containerd
systemctl start kubelet

# Fetch join information and join cluster
echo "Fetching cluster join information..."
MAX_ATTEMPTS=10
ATTEMPT=0

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    if aws s3 cp s3://tfaws-dev-secrets/clusters/$CLUSTER_NAME/join-info.json /tmp/join-info.json 2>/dev/null; then
        TOKEN=$(jq -r '.token' /tmp/join-info.json)
        HASH=$(jq -r '.ca_cert_hash' /tmp/join-info.json)
        ENDPOINT=$(jq -r '.master_endpoint' /tmp/join-info.json)
        
        echo "Joining cluster at $ENDPOINT..."
        if kubeadm join $ENDPOINT --token $TOKEN --discovery-token-ca-cert-hash $HASH; then
            echo "Successfully joined cluster"
            echo "$(date)" > /var/log/k8s-worker-runtime-complete
            rm /tmp/join-info.json
            exit 0
        else
            echo "Join attempt failed, retrying..."
        fi
        rm /tmp/join-info.json
    else
        echo "Join info not available yet, waiting..."
    fi
    
    ATTEMPT=$((ATTEMPT+1))
    sleep 30
done

echo "FATAL: Failed to join cluster after $MAX_ATTEMPTS attempts"
shutdown -h now