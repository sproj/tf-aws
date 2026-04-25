terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "worker_nodes" {
  source                    = "../../../../modules/deployment-types/kubernetes-ec2/worker_nodes"
  public_subnet_ids         = var.public_subnet_ids
  security_group_ids        = var.security_group_ids
  iam_instance_profile_name = var.instance_profile_name
  ami_id                    = var.ami_id
  name_prefix               = var.name_prefix
  instance_type             = var.instance_type
  root_volume_size          = var.root_volume_size
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_capacity
  tags = {
    Environment    = "dev"
    NodeType       = "worker"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}
