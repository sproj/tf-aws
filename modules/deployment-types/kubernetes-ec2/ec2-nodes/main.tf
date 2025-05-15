resource "aws_launch_template" "nodes" {
  name_prefix   = "${var.name_prefix}-nodes-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  vpc_security_group_ids = var.security_group_ids

  tag_specifications {
    resource_type = "instance"
    tags         = merge(var.tags, { Name = "${var.name_prefix}-node" })
  }
}

resource "aws_autoscaling_group" "nodes" {
  name_prefix          = "${var.name_prefix}-nodes-"
  min_size             = var.min_size
  max_size             = var.max_size
  desired_capacity     = var.desired_capacity
  vpc_zone_identifier  = var.subnet_ids
  launch_template {
    id      = aws_launch_template.nodes.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-node"
    propagate_at_launch = true
  }
  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}