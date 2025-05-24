module "networking" {
  source                    = "../../../infrastructure/networking"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  availability_zones        = var.availability_zones
  name_prefix               = var.name_prefix
  tags                      = var.tags
}

module "iam_instance_profile" {
  source              = "../../../infrastructure/iam-instance-profile"
  name_prefix         = var.name_prefix
  tags                = var.tags
  service_name        = "ec2-nodes"
  service_identifiers = ["ec2.amazonaws.com"]
}

module "worker_nodes_sg" {
  source = "../../../infrastructure/security-groups"

  name        = "${var.name_prefix}-nodes"
  description = "Security group for Kubernetes nodes"
  vpc_id      = module.networking.vpc_id
  tags        = var.tags

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
      description = "SSH access"
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr_block]
      description = "All traffic from VPC"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}

module "master_sg" {
  source = "../../../infrastructure/security-groups"

  name        = "${var.name_prefix}-master"
  description = "Security group for Kubernetes master node"
  vpc_id      = module.networking.vpc_id
  tags        = var.tags

  ingress_rules = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
      description = "SSH access - user IP only"
    },
    {
      from_port   = 6443
      to_port     = 6443
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Kubernetes API"
    },
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
      description = "Node/master communication"
    },
    {
      from_port   = 0
      protocol    = "udp"
      to_port     = 65535
      cidr_blocks = [var.vpc_cidr_block]
      description = "Node/master UDP communication (flannel)"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}
