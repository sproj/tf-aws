packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "kubernetes_version" {
  type    = string
  default = "1.33"
}

variable "ami_name_prefix" {
  type    = string
  default = "k8s-base"
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "k8s_base" {
  ami_name      = "${var.ami_name_prefix}-${var.kubernetes_version}-${local.timestamp}"
  instance_type = "t3.small"
  region        = var.region

  vpc_id    = var.vpc_id
  subnet_id = var.subnet_id

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"] # Canonical
  }

  ssh_username = "ubuntu"

  tags = {
    Name              = "${var.ami_name_prefix}-${var.kubernetes_version}"
    KubernetesVersion = var.kubernetes_version
    OS                = "Ubuntu 22.04"
    CreatedBy         = "Packer"
    CreatedAt         = timestamp()
    Project           = "tfaws-learning"
    AutoCleanup       = "true"
    Environment       = "dev"
    RetentionDays     = "30"
  }
}

build {
  name = "k8s-base"
  sources = [
    "source.amazon-ebs.k8s_base"
  ]


  # Update system packages
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y"
    ]
  }

  # Install prerequisites
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      # Update package lists first
      "sudo apt-get update",

      # Install basic prerequisites 
      "sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release",

      # Install jq (different package name on Ubuntu 22.04)
      "sudo apt-get install -y jq",

      # Install AWS CLI v2 (awscli v1 package doesn't exist on 22.04)
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip",
      "sudo apt-get install -y unzip",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "rm -rf aws awscliv2.zip",

      "echo 'Prerequisites installed successfully'"
    ]
  }

  # Configure network settings for Kubernetes
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.conf",
      "echo 'net.bridge.bridge-nf-call-iptables = 1' | sudo tee -a /etc/sysctl.d/k8s.conf",
      "echo 'net.bridge.bridge-nf-call-ip6tables = 1' | sudo tee -a /etc/sysctl.d/k8s.conf",
      "echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/k8s.conf",
      "sudo modprobe br_netfilter",
      "sudo modprobe overlay",
      "echo 'br_netfilter' | sudo tee -a /etc/modules-load.d/k8s.conf",
      "echo 'overlay' | sudo tee -a /etc/modules-load.d/k8s.conf"
    ]
  }

  # Install and configure containerd
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo apt-get install -y containerd",
      "sudo mkdir -p /etc/containerd",
      "containerd config default | sudo tee /etc/containerd/config.toml",
      "sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml",
      "sudo systemctl enable containerd"
    ]
  }

  # Disable swap permanently
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo swapoff -a",
      "sudo sed -i '/swap/d' /etc/fstab"
    ]
  }

  # Install Kubernetes components
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo mkdir -p /etc/apt/keyrings",
      "curl -fsSL https://pkgs.k8s.io/core:/stable:/v${var.kubernetes_version}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg",
      "echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${var.kubernetes_version}/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list",
      "sudo apt-get update",
      "sudo apt-get install -y kubelet kubeadm kubectl",
      "sudo apt-mark hold kubelet kubeadm kubectl",
      "sudo systemctl enable kubelet"
    ]
  }

  # Create directories for scripts and configs
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo mkdir -p /opt/k8s-scripts",
      "sudo chown ubuntu:ubuntu /opt/k8s-scripts"
    ]
  }

  # Clean up to reduce AMI size
  provisioner "shell" {
    environment_vars = [
      "DEBIAN_FRONTEND=noninteractive"
    ]
    inline = [
      "sudo apt-get autoremove -y",
      "sudo apt-get autoclean",
      "sudo rm -rf /var/lib/apt/lists/*",
      "sudo rm -rf /tmp/*",
      "sudo rm -rf /var/tmp/*",
      # clear bash history files directly:
      "sudo rm -f /root/.bash_history",
      "rm -f /home/ubuntu/.bash_history",
      
      # Clear other logs that might contain sensitive info:
      "sudo rm -f /var/log/cloud-init*.log",
      "sudo rm -f /var/log/auth.log*",
      
      "echo 'Cleanup completed successfully'"
    ]
  }
}
