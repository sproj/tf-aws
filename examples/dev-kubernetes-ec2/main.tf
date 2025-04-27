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

module "networking" {
  source = "../../modules/deployment-types/kubernetes-ec2/networking"

  name_prefix               = "dev-k8s"
  vpc_cidr_block            = "10.0.0.0/16"
  public_subnet_cidr_blocks = ["10.0.1.0/24"]
  availability_zones        = ["eu-west-1a"]

  tags = {
    Environment    = "dev"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}
