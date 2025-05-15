resource "aws_security_group" "nodes" {
  name        = "${var.name_prefix}-nodes"
  description = "Security group for Kubernetes nodes"
  vpc_id      = var.vpc_id

  # Example ingress/egress rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # this is open to the internet - clamp it to my own ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # this is open to the internet - clamp it to my own ip
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-nodes-sg" })
}

resource "aws_security_group" "master" {
  name        = "${var.name_prefix}-master"
  description = "Security group for Kubernetes master node"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP for production
  }

  ingress {
    description = "Kubernetes API"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IP or VPC for production
  }

  ingress {
    description = "Node/master communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name_prefix}-master-sg" })
}