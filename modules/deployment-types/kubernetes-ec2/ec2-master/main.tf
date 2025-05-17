resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
  
    # Install containerd
    apt-get install -y containerd
    systemctl enable containerd
    systemctl start containerd
  
    # Enable IP forwarding (required for Kubernetes)
    echo 1 > /proc/sys/net/ipv4/ip_forward
    echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
    sysctl -p
  
    # Configure containerd to use systemd cgroup driver
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    systemctl restart containerd
  
    # Disable swap (required for Kubernetes)
    swapoff -a
    sed -i '/swap/d' /etc/fstab
  
    # Kubernetes repo
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    systemctl enable kubelet && systemctl start kubelet
  
    # Initialize Kubernetes with explicit success check
    PRIVATE_IP=$(hostname -I | awk '{print $1}')
    kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=$PRIVATE_IP
  
    # Check if kubeadm init was successful
    if [ -f /etc/kubernetes/admin.conf ]; then
      mkdir -p /home/ubuntu/.kube
      cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
      chown ubuntu:ubuntu /home/ubuntu/.kube/config

      # Add tls-server-name to kubeconfig
      sudo -u ubuntu kubectl config set-cluster kubernetes --kubeconfig=/home/ubuntu/.kube/config --tls-server-name=$PRIVATE_IP
    
      # Wait for API server to be fully ready
      echo "Waiting for API server to be ready..."
      sleep 30
    
      # Try with explicit retries
      MAX_RETRIES=10
      RETRY_INTERVAL=10
      attempt=0
      until sudo -u ubuntu KUBECONFIG=/home/ubuntu/.kube/config kubectl get nodes || [ $attempt -eq $MAX_RETRIES ]; do
        echo "Attempt $((++attempt))/$MAX_RETRIES: API server not ready yet. Waiting $RETRY_INTERVAL seconds..."
        sleep $RETRY_INTERVAL
        # Increase wait time for subsequent retries
        RETRY_INTERVAL=$((RETRY_INTERVAL + 5))
      done
    
      if [ $attempt -eq $MAX_RETRIES ]; then
        echo "API server not ready after $MAX_RETRIES attempts. Continuing anyway..."
      else
        echo "API server is ready!"
      fi
      
      # Apply Flannel network addon with explicit kubeconfig
      echo "Applying Flannel network addon..."
      sudo -u ubuntu KUBECONFIG=/home/ubuntu/.kube/config kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
    
      # Allow scheduling pods on master (single node)
      echo "Removing taint from control-plane node..."
      sudo -u ubuntu KUBECONFIG=/home/ubuntu/.kube/config kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
    
      echo "kubeadm init and network setup succeeded."
    else
      echo "kubeadm init failed! Check logs for errors."
      exit 1
    fi
  EOF
  )

  tags = merge(var.tags, { Name = "${var.name_prefix}-master" })
}
