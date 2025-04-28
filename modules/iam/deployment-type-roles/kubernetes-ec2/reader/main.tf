resource "aws_iam_role" "kubernetes_ec2_reader" {
  name = "k8s-ec2-reader"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.bootstrapper_role_name}"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name      = "k8s-ec2-reader"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_role_policy_attachment" "reader_backend_access" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = var.backend_readonly_access_policy_arn
}

data "aws_caller_identity" "current" {}

# reader networking access
data "aws_iam_policy_document" "kubernetes_ec2_reader_networking_access" {
  statement {
    sid       = "AllowNetworkingDescriptionActions"
    effect    = "Allow"
    actions   = var.networking_allowed_actions
    resources = ["*"]
  }
}

# reader networking policy
resource "aws_iam_policy" "kubernetes_ec2_reader_networking_policy" {
  name        = "kubernetes-ec2-reader-networking-policy"
  description = "Policy allowing kubernetes-ec2-reader to read networking resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_reader_networking_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach reader networking policy
resource "aws_iam_role_policy_attachment" "reader_attach_networking_policy" {
  role       = aws_iam_role.kubernetes_ec2_reader
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_networking_policy
}

# reader ec2 policy
resource "aws_iam_policy" "kubernetes_ec2_reader_ec2_policy" {
  name        = "kubernetes-ec2-reader-ec2-policy"
  description = "Policy allowing kubernetes-ec2-reader to create ec2 resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_ec2_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}
# attach creator ec2 policy
resource "aws_iam_role_policy_attachment" "reader_attach_ec2_policy" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_ec2_policy.arn
}

# reader elasticloadbalancing actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_elasticloadbalancing_access" {
  statement {
    sid       = "AllowElasticLoadbalancingDescriptionActions"
    effect    = "Allow"
    actions   = var.elasticloadbalancing_allowed_actions
    resources = ["*"]
  }
}

# reader elasticloadbalancing policy
resource "aws_iam_policy" "kubernetes_ec2_reader_elasticloadbalancing_policy" {
  name        = "kubernetes-ec2-reader-elasticloadbalancing-policy"
  description = "Policy allowing kubernetes-ec2-reader to manage elasticloadbalancing resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_elasticloadbalancing_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach reader elasticloadbalancing policy
resource "aws_iam_role_policy_attachment" "reader_attach_elasticloadbalancing_policy" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_elasticloadbalancing_policy.arn
}

# reader autoscaling actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_autoscaling_access" {
  statement {
    sid       = "AllowAutoScalingDescriptionActions"
    effect    = "Allow"
    actions   = var.autoscaling_allowed_actions
    resources = ["*"]
  }
}

# reader autoscaling policy
resource "aws_iam_policy" "kubernetes_ec2_reader_autoscaling_policy" {
  name        = "kubernetes-ec2-creator-autoscaling-policy"
  description = "Policy allowing kubernetes-ec2-reader to manage autoscaling resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_autoscaling_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach reader autoscaling policy
resource "aws_iam_role_policy_attachment" "reader_attach_autoscaling_policy" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_autoscaling_policy.arn
}

# reader iam actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_iam_access" {
  statement {
    sid       = "AllowIAMDescriptionActions"
    effect    = "Allow"
    actions   = var.iam_allowed_actions
    resources = ["*"]
  }
}

# reader iam policy
resource "aws_iam_policy" "kubernetes_ec2_reader_iam_policy" {
  name        = "kubernetes-ec2-reader-iam-policy"
  description = "Policy allowing kubernetes-ec2-reader to manage iam resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_iam_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach reader iam policy
resource "aws_iam_role_policy_attachment" "reader_attach_iam_policy" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_iam_policy.arn
}

# reader ecr actions
data "aws_iam_policy_document" "kubernetes_ec2_reader_ecr_access" {
  statement {
    sid       = "AllowECRDescriptionActions"
    effect    = "Allow"
    actions   = var.iam_allowed_actions
    resources = ["*"]
  }
}

# reader ecr policy
resource "aws_iam_policy" "kubernetes_ec2_reader_ecr_policy" {
  name        = "kubernetes-ec2-reader-ecr-policy"
  description = "Policy allowing kubernetes-ec2-reader to describe ecr resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_reader_ecr_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach reader ecr policy
resource "aws_iam_role_policy_attachment" "reader_attach_ecr_policy" {
  role       = aws_iam_role.kubernetes_ec2_reader.name
  policy_arn = aws_iam_policy.kubernetes_ec2_reader_ecr_policy.arn
}


