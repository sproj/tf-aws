#!/bin/bash
# check-k8s-init.sh
# Usage: ./check-k8s-init.sh <master_public_ip> <ssh_key>

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 <master_public_ip> <ssh_key_file>"
  exit 1
fi

MASTER_IP="$1"
SSH_KEY="$2"

echo "Checking Kubernetes initialization status on $MASTER_IP..."
ssh -i "$SSH_KEY" ubuntu@$MASTER_IP "sudo tail -n 50 /var/log/k8s-master-init.log"

echo ""
echo "Checking if initialization is complete..."
ssh -i "$SSH_KEY" ubuntu@$MASTER_IP "if [ -f /var/log/k8s-master-init.done ]; then echo 'Initialization complete!'; else echo 'Initialization still in progress...'; fi"

echo ""
echo "Current pod status:"
ssh -i "$SSH_KEY" ubuntu@$MASTER_IP "kubectl get pods --all-namespaces"