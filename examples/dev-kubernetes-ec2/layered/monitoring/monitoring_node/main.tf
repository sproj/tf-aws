terraform {
  required_version = ">= 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "kubernetes-ec2-creator"
}

data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "examples/kubernetes-ec2/layered/terraform.tfstate"
    region  = "eu-west-1"
    profile = "kubernetes-ec2-creator"
  }
}

module "monitoring_node" {
  source                    = "../../../../modules/deployment-types/kubernetes-ec2/worker_nodes"
  public_subnet_ids         = data.terraform_remote_state.infra.outputs.public_subnet_ids
  security_group_ids        = [data.terraform_remote_state.infra.outputs.node_security_group_id]
  iam_instance_profile_name = data.terraform_remote_state.infra.outputs.iam_instance_profile_name
  ami_id                    = var.ami_id
  name_prefix               = "${var.name_prefix}-monitoring"
  instance_type             = var.instance_type
  root_volume_size          = var.root_volume_size
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_capacity
  extra_kubelet_arguments   = "--register-with-taints=dedicated=monitoring:NoSchedule --node-labels=dedicated=monitoring"
  tags = {
    Environment    = "dev"
    NodeType       = "monitoring"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
    dedicated      = "monitoring"
  }
}
