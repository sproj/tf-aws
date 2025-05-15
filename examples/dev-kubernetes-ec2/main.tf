terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "examples/kubernetes-ec2-networking/terraform.tfstate"
    region         = "eu-west-1"
    profile        = "kubernetes-ec2-creator"
    dynamodb_table = "tfaws-dev-lock-backend"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "kubernetes-ec2-creator"
}

module "kubernetes_ec2" {
  source                    = "../../modules/deployment-types/kubernetes-ec2"
  aws_region                = "eu-west-1"
  vpc_cidr_block            = "10.10.0.0/16"
  public_subnet_cidr_blocks = ["10.10.1.0/24"]
  availability_zones        = ["eu-west-1a"]
  name_prefix               = "dev-k8s"
  node_ami_id = "ami-09079da11cd2861fa" # ubuntu 22.04 LTS (eu-west-1) - check https://cloud-images.ubuntu.com/locator/ec2/
  tags = {
    Environment    = "dev"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}

# module "networking" {
#   source = "../../modules/deployment-types/kubernetes-ec2/networking"

#   name_prefix               = "dev-k8s"
#   vpc_cidr_block            = "10.0.0.0/16"
#   public_subnet_cidr_blocks = ["10.0.1.0/24"]
#   availability_zones        = ["eu-west-1a"]

#   tags = {
#     Environment    = "dev"
#     DeploymentType = "kubernetes-ec2"
#     ManagedBy      = "terraform"
#   }
# }

## only need outputs which come from a deployment module if they are intended to be used here.
# output "vpc_id" {
#   value = module.networking.vpc_id
# }

# output "public_subnet_ids" {
#   value = module.networking.public_subnet_ids
# }
