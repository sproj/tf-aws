resource "aws_iam_role" "instance_role" {
  name               = "${var.name_prefix}-${var.service_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = var.service_identifiers
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.name_prefix}-${var.service_name}-profile"
  role = aws_iam_role.instance_role.name
  tags = var.tags
}
