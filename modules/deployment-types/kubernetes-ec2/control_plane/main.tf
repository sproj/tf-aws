module "ec2_master" {
  source               = "./ec2-master"
  subnet_id            = var.public_subnet_ids[0]
  security_group_ids   = var.security_group_ids
  iam_instance_profile = var.iam_instance_profile_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  key_name             = var.key_name
  name_prefix          = var.name_prefix
  tags                 = var.tags
}
