resource "aws_security_group" "nodes" {
  name        = "${var.name_prefix}-nodes"
  description = "Security group for Kubernetes nodes"
  vpc_id      = var.vpc_id

  # SSH access - restricted to user local IPv4
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ssh_cidr}"]
  }

  # Allow all traffic from within the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.vpc_cidr_block}"]
  }

  # Allow all outbound traffic 
  # can be restricted further
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name_prefix}-nodes-sg" })
}

resource "aws_security_group" "master" {
  name        = "${var.name_prefix}-master"
  description = "Security group for Kubernetes master node"
  vpc_id      = var.vpc_id

  # ssh access - user ip only
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allowed_ssh_cidr}"]
  }

  # Kubernetes API - since using SSH tunneling, 
  # can restrict this to the VPC only
  # If k8s api access over public IP is done then this will no longer be the case.
  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all traffic between nodes and master
  ingress {
    description = "Node/master communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all traffic between nodes and master over UDP
  ingress {
    description = "Node/master UDP communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-master-sg" })
}
