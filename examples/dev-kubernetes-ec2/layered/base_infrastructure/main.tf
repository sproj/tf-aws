terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "examples/kubernetes-ec2/base_infrastructure/terraform.tfstate"
    region         = "eu-west-1"
    profile        = "kubernetes-ec2-creator"
    dynamodb_table = "tfaws-dev-lock-backend"
  }
}

provider "aws" {
  region  = "eu-west-1"
  profile = "kubernetes-ec2-creator"
}

module "ebs_csi_policy" {
  source      = "../../../../modules/infrastructure/ebs-csi-policy"
  name_prefix = var.name_prefix
}

module "ssm_policies" {
  source      = "../../../../modules/infrastructure/ssm-policies"
  name_prefix = var.name_prefix
  env         = var.env
}

module "base_infrastructure" {
  source                    = "../../../../modules/deployment-types/kubernetes-ec2/base_infrastructure"
  vpc_cidr_block            = "10.10.0.0/16"
  public_subnet_cidr_blocks = ["10.10.1.0/24"]
  availability_zones        = ["eu-west-1a"]
  allowed_ssh_cidr          = "${var.allowed_ssh_cidr}/32"
  name_prefix               = var.name_prefix
  env                       = var.env
  subnet_tags               = { "kubernetes.io/role/elb" : 1, "kubernetes.io/cluster/${var.name_prefix}" : "shared" }
  additional_instance_policy_arns = [
    module.ebs_csi_policy.policy_arn,
    module.ssm_policies.ssm_read_policy_arn,
    module.ssm_policies.ssm_write_policy_arn
  ]

  tags = {
    Environment    = "${var.env}"
    DeploymentType = "kubernetes-ec2"
    ManagedBy      = "terraform"
  }
}
