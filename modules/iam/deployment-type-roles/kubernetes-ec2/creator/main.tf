resource "aws_iam_role" "kubernetes_ec2_creator" {
  name = "k8s-ec2-creator"

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
    Name      = "k8s-ec2-creator"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach creator backend access policy
resource "aws_iam_role_policy_attachment" "creator_backend_access" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = var.backend_full_access_policy_arn
}

data "aws_caller_identity" "current" {}

# creator networking access
data "aws_iam_policy_document" "kubernetes_ec2_creator_networking_access" {
  statement {
    sid       = "AllowNetworkingCreationActions"
    effect    = "Allow"
    actions   = var.networking_allowed_actions
    resources = ["*"]
  }
}

# creator networking policy
resource "aws_iam_policy" "kubernetes_ec2_creator_networking_policy" {
  name        = "kubernetes-ec2-creator-networking-policy"
  description = "Policy allowing kubernetes-ec2-creator to create networking resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_creator_networking_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach creator networking policy
resource "aws_iam_role_policy_attachment" "creator_networking_access" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_networking_policy.arn
}

# creator ec2 actions
data "aws_iam_policy_document" "kubernetes_ec2_creator_ec2_access" {
  statement {
    sid       = "AllowEC2CreationActions"
    effect    = "Allow"
    actions   = var.ec2_allowed_actions
    resources = ["*"]
  }
}
# creator ec2 policy
resource "aws_iam_policy" "kubernetes_ec2_creator_ec2_policy" {
  name        = "kubernetes-ec2-creator-ec2-policy"
  description = "Policy allowing kubernetes-ec2-creator to create ec2 resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_creator_ec2_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}
# attach creator ec2 policy
resource "aws_iam_role_policy_attachment" "creator_attach" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_ec2_policy.arn
}

# creator elasticloadbalancing actions
data "aws_iam_policy_document" "kubernetes_ec2_creator_elasticloadbalancing_access" {
  statement {
    sid       = "AllowElasticLoadbalancingCreationActions"
    effect    = "Allow"
    actions   = var.elasticloadbalancing_allowed_actions
    resources = ["*"]
  }
}

# creator elasticloadbalancing policy
resource "aws_iam_policy" "kubernetes_ec2_creator_elasticloadbalancing_policy" {
  name        = "kubernetes-ec2-creator-elasticloadbalancing-policy"
  description = "Policy allowing kubernetes-ec2-creator to create elasticloadbalancing resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_creator_elasticloadbalancing_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach creator elasticloadbalancing policy
resource "aws_iam_role_policy_attachment" "creator_attach" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_elasticloadbalancing_policy.arn
}

# creator autoscaling actions
data "aws_iam_policy_document" "kubernetes_ec2_creator_autoscaling_access" {
  statement {
    sid       = "AllowAutoScalingCreationActions"
    effect    = "Allow"
    actions   = var.autoscaling_allowed_actions
    resources = ["*"]
  }
}

# creator autoscaling policy
resource "aws_iam_policy" "kubernetes_ec2_creator_autoscaling_policy" {
  name        = "kubernetes-ec2-creator-autoscaling-policy"
  description = "Policy allowing kubernetes-ec2-creator to create autoscaling resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_creator_autoscaling_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach creator autoscaling policy
resource "aws_iam_role_policy_attachment" "creator_attach" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_autoscaling_policy.arn
}

# creator iam actions
data "aws_iam_policy_document" "kubernetes_ec2_creator_iam_access" {
  statement {
    sid       = "AllowIAMCreationActions"
    effect    = "Allow"
    actions   = var.iam_allowed_actions
    resources = ["*"]
  }
}

# creator iam policy
resource "aws_iam_policy" "kubernetes_ec2_creator_iam_policy" {
  name        = "kubernetes-ec2-creator-iam-policy"
  description = "Policy allowing kubernetes-ec2-creator to create iam resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_creator_iam_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach creator iam policy
resource "aws_iam_role_policy_attachment" "creator_attach" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_iam_policy.arn
}

# creator ecr actions
data "aws_iam_policy_document" "kubernetes_ec2_creator_ecr_access" {
  statement {
    sid       = "AllowECRCreationActions"
    effect    = "Allow"
    actions   = var.iam_allowed_actions
    resources = ["*"]
  }
}

# creator ecr policy
resource "aws_iam_policy" "kubernetes_ec2_creator_ecr_policy" {
  name        = "kubernetes-ec2-creator-ecr-policy"
  description = "Policy allowing kubernetes-ec2-creator to create ecr resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_creator_ecr_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach creator ecr policy
resource "aws_iam_role_policy_attachment" "creator_attach" {
  role       = aws_iam_role.kubernetes_ec2_creator.name
  policy_arn = aws_iam_policy.kubernetes_ec2_creator_ecr_policy.arn
}
