terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "control_plane" {
  source                    = "../../../../modules/deployment-types/kubernetes-ec2/control_plane"
  public_subnet_ids         = var.public_subnet_ids
  security_group_ids        = var.security_group_ids
  ami_id                    = var.ami_id
  iam_instance_profile_name = var.instance_profile_name
  name_prefix               = var.name_prefix
  key_name                  = "${var.name_prefix}-key"
  instance_type             = var.instance_type
  root_volume_size          = var.root_volume_size
  tags = {
    Environment    = "dev"
    NodeType       = "control"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}
