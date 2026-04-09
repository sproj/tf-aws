#!/bin/bash
# Safe kubeconfig merge script - takes cluster name as parameter
# Usage: ./merge_kubeconfig.sh <cluster_name> <master_public_ip> <master_private_ip>

set -e  # Exit on any error

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <cluster_name> <master_public_ip> <master_private_ip>"
    echo "Example: $0 dev-k8s 54.195.174.192 10.10.1.16"
    exit 1
fi

CLUSTER_NAME="$1"
MASTER_IP="$2"
MASTER_PRIVATE_IP="$3"
TEMP_CONFIG="$HOME/.kube/${CLUSTER_NAME}_temp_config"
BACKUP_CONFIG="$HOME/.kube/config.backup.$(date +%Y%m%d_%H%M%S)"

echo "Step 1: Download cluster config from master node ($MASTER_IP)"
scp -i ~/.ssh/${CLUSTER_NAME}-key ubuntu@${MASTER_IP}:/home/ubuntu/.kube/config ${TEMP_CONFIG}

echo "Step 2: Backup existing config"
cp $HOME/.kube/config ${BACKUP_CONFIG}

echo "Step 3: Rename context in downloaded config to avoid conflicts"
# Get the current context name from the downloaded config
CURRENT_CONTEXT=$(kubectl --kubeconfig=${TEMP_CONFIG} config current-context)
echo "Found context: ${CURRENT_CONTEXT}"
kubectl --kubeconfig=${TEMP_CONFIG} config rename-context ${CURRENT_CONTEXT} ${CLUSTER_NAME}

echo "Step 4: Remove any existing context with the same name"
kubectl config delete-context ${CLUSTER_NAME} 2>/dev/null || echo "No existing ${CLUSTER_NAME} context to remove"

echo "Step 5: Merge the new config"
export KUBECONFIG=${TEMP_CONFIG}:$HOME/.kube/config
kubectl config view --flatten > $HOME/.kube/config.new

echo "step 6: Set tls-server-name to cluster private IP and server to localhost:6443"
kubectl config set-cluster kubernetes --tls-server-name=$(MASTER_PRIVATE_IP) --server=https://127.0.0.1:6443

echo "Step 7: Replace config atomically"
mv $HOME/.kube/config.new $HOME/.kube/config

echo "Step 8: Cleanup temporary files"
rm ${TEMP_CONFIG}
unset KUBECONFIG

echo "Step 9: Verify the merge worked"
echo "Available contexts:"
kubectl config get-contexts

echo ""
echo "✅ Successfully merged ${CLUSTER_NAME} cluster config!"
echo "💾 Backup saved to: ${BACKUP_CONFIG}"
echo "🔄 To switch to the new cluster: kubectl config use-context ${CLUSTER_NAME}"