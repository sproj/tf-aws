terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "examples/kubernetes-ec2/control_plane/terraform.tfstate"
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

module "control_plane" {
  source                    = "../../../../modules/deployment-types/kubernetes-ec2/control_plane"
  public_subnet_ids         = data.terraform_remote_state.base_infrastructure.outputs.public_subnet_ids
  security_group_ids        = [data.terraform_remote_state.base_infrastructure.outputs.master_security_group_id]
  ami_id                    = var.ami_id
  iam_instance_profile_name = data.terraform_remote_state.base_infrastructure.outputs.instance_profile_name
  name_prefix               = var.name_prefix
  key_name                  = "${var.name_prefix}-key"
  tags = {
    Environment    = "dev"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}
