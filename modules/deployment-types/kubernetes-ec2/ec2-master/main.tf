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

  # Kubernetes repo (new method)
  mkdir -p /etc/apt/keyrings
  curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /" > /etc/apt/sources.list.d/kubernetes.list
  apt-get update
  apt-get install -y kubelet kubeadm kubectl
  systemctl enable kubelet && systemctl start kubelet

  kubeadm init --pod-network-cidr=10.244.0.0/16

  mkdir -p /home/ubuntu/.kube
  cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
  chown ubuntu:ubuntu /home/ubuntu/.kube/config

  sudo -u ubuntu kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  # Allow scheduling pods on master (single node)
  # sudo -u ubuntu -c kubectl taint nodes --all node-role.kubernetes.io/control-plane- || true
EOF
  )

  tags = merge(var.tags, { Name = "${var.name_prefix}-master" })
}
