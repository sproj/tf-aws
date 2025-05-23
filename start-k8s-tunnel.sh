#!/bin/bash
# Usage: ./start-k8s-tunnel.sh <bastion_host> <private_ip> <ssh_key_name> [local_port]
# Example: ./start-k8s-tunnel.sh 52.16.142.104 ip-10-10-1-228 dev-k8s-key 6443

if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <bastion_host> <private_ip> <ssh_key_name> [local_port]"
    exit 1
fi

BASTION_USER=ubuntu
BASTION_HOST="$1"
PRIVATE_IP="$2"
SSH_KEY=~/.ssh/"$3"
LOCAL_PORT="${4:-6443}"

# Start SSH tunnel in the background
echo "Starting SSH tunnel to $PRIVATE_IP:6443 via $BASTION_HOST..."
# ssh -i "$SSH_KEY" -N -L ${LOCAL_PORT}:${PRIVATE_IP}:6443 ${BASTION_USER}@${BASTION_HOST} \
ssh -i "$SSH_KEY" -N -L 127.0.0.1:${LOCAL_PORT}:${PRIVATE_IP}:6443 ${BASTION_USER}@${BASTION_HOST} \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=60 \
    -f

if [ $? -eq 0 ]; then
    echo "SSH tunnel started. You can now use kubectl with server: https://localhost:6443"
    echo "To stop the tunnel, run: pkill -f '${PRIVATE_IP}:6443'"
else
    echo "Failed to start SSH tunnel."
fi