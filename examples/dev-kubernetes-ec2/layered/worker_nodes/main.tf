terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "examples/kubernetes-ec2/worker_nodes/terraform.tfstate"
    region         = "eu-west-1"
    profile        = "kubernetes-ec2-creator"
    dynamodb_table = "tfaws-dev-lock-backend"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "kubernetes-ec2-creator"
}

# Pull outputs from base_infrastructure layer
data "terraform_remote_state" "base_infrastructure" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "examples/kubernetes-ec2/base_infrastructure/terraform.tfstate"
    region  = "eu-west-1"
    profile = "kubernetes-ec2-creator"
  }
}

# Pull outputs from control_plane layer
data "terraform_remote_state" "control_plane" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "examples/kubernetes-ec2/control_plane/terraform.tfstate"
    region  = "eu-west-1"
    profile = "kubernetes-ec2-creator"
  }
}

module "worker_nodes" {
  source                    = "../../../../modules/deployment-types/kubernetes-ec2/worker_nodes"
  public_subnet_ids         = data.terraform_remote_state.base_infrastructure.outputs.public_subnet_ids
  security_group_ids        = [data.terraform_remote_state.base_infrastructure.outputs.master_security_group_id]
  iam_instance_profile_name = data.terraform_remote_state.base_infrastructure.outputs.instance_profile_name
  ami_id                    = var.ami_id
  name_prefix               = var.name_prefix
  instance_type             = var.instance_type
  root_volume_size          = var.root_volume_size
  desired_capacity          = var.asg_desired_capacity
  max_size                  = var.asg_max_capacity
  tags = {
    Environment    = "dev"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}
