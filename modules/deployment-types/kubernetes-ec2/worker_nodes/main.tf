module "ec2_nodes" {
  source               = "../../../infrastructure/autoscaling-group"
  subnet_ids           = var.public_subnet_ids
  security_group_ids   = var.security_groups.node_sg_ids
  iam_instance_profile = var.iam_instance_profile.profile_name
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  desired_capacity     = var.desired_capacity
  min_size             = var.min_size
  max_size             = var.max_size
  name                 = "${var.name_prefix}-nodes"
  tags                 = var.tags
}
