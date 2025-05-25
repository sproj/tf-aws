resource "aws_iam_role" "instance_role" {
  name               = "${var.name_prefix}-${var.service_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = var.tags
}

# trust policy - who can assume the role
data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = var.service_identifiers
    }
    actions = [
      "sts:AssumeRole",
    ]
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.name_prefix}-${var.service_name}-profile"
  role = aws_iam_role.instance_role.name
  tags = var.tags
}

# Permissions policy (what the role can do)
data "aws_iam_policy_document" "s3_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = [
      "arn:aws:s3:::tfaws-${var.env}-secrets/clusters/*/join-info.json"
    ]
  }
}

resource "aws_iam_policy" "s3_permissions" {
  name   = "${var.name_prefix}-${var.service_name}-s3-policy"
  policy = data.aws_iam_policy_document.s3_permissions.json
}

resource "aws_iam_role_policy_attachment" "s3_permissions" {
  role       = aws_iam_role.instance_role.name
  policy_arn = aws_iam_policy.s3_permissions.arn
}
