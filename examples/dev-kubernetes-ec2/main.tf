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
  key_name                  = "dev-k8s-key"
  node_ami_id               = "ami-09079da11cd2861fa" # ubuntu 22.04 LTS (eu-west-1) - check https://cloud-images.ubuntu.com/locator/ec2/
  master_ami_id             = "ami-09079da11cd2861fa"
  tags = {
    Environment    = "dev"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}
