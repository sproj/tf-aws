module "networking" {
  source                    = "../../../infrastructure/networking"
  vpc_cidr_block            = var.vpc_cidr_block
  public_subnet_cidr_blocks = var.public_subnet_cidr_blocks
  availability_zones        = var.availability_zones
  name_prefix               = var.name_prefix
  tags                      = var.tags
}

module "security_groups" {
  source           = "./security-groups"
  vpc_id           = module.networking.vpc_id
  vpc_cidr_block   = var.vpc_cidr_block
  allowed_ssh_cidr = var.allowed_ssh_cidr
  name_prefix      = var.name_prefix
  tags             = var.tags
}

module "iam_instance_profile" {
  source              = "../../../infrastructure/iam-instance-profile"
  name_prefix         = var.name_prefix
  tags                = var.tags
  service_name        = "ec2-nodes"
  service_identifiers = ["ec2.amazonaws.com"]
}
