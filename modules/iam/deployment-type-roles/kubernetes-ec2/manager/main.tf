resource "aws_iam_role" "kubernetes_ec2_manager" {
  name = "k8s-ec2-manager"

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
    Name      = "k8s-ec2-manager"
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

resource "aws_iam_role_policy_attachment" "manager_backend_access" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = var.backend_full_access_policy_arn
}


data "aws_caller_identity" "current" {}

# manager networking access
data "aws_iam_policy_document" "kubernetes_ec2_manager_networking_access" {
  statement {
    sid       = "AllowNetworkingManagementActions"
    effect    = "Allow"
    actions   = var.networking_allowed_actions
    resources = ["*"]
  }
}

# manager networking policy
resource "aws_iam_policy" "kubernetes_ec2_manager_networking_policy" {
  name        = "kubernetes-ec2-manager-networking-policy"
  description = "Policy allowing kubernetes-ec2-manager to manage networking resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_networking_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach manager networking policy
resource "aws_iam_role_policy_attachment" "manager_attach_networking_policy" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = aws_iam_policy.kubernetes_ec2_manager_networking_policy
}

# manager ec2 actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_ec2_access" {
  statement {
    sid       = "AllowEC2CreationActions"
    effect    = "Allow"
    actions   = var.ec2_allowed_actions
    resources = ["*"]
  }
}

# manager ec2 policy
resource "aws_iam_policy" "kubernetes_ec2_manager_ec2_policy" {
  name        = "kubernetes-ec2-manager-ec2-policy"
  description = "Policy allowing kubernetes-ec2-manager to create ec2 resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_ec2_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}
# attach creator ec2 policy
resource "aws_iam_role_policy_attachment" "manager_attach_ec2_policy" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = aws_iam_policy.kubernetes_ec2_manager_ec2_policy.arn
}

# manager elasticloadbalancing actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_elasticloadbalancing_access" {
  statement {
    sid       = "AllowElasticLoadbalancingManagementActions"
    effect    = "Allow"
    actions   = var.elasticloadbalancing_allowed_actions
    resources = ["*"]
  }
}

# manager elasticloadbalancing policy
resource "aws_iam_policy" "kubernetes_ec2_manager_elasticloadbalancing_policy" {
  name        = "kubernetes-ec2-manager-elasticloadbalancing-policy"
  description = "Policy allowing kubernetes-ec2-manager to manage elasticloadbalancing resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_elasticloadbalancing_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach manager elasticloadbalancing policy
resource "aws_iam_role_policy_attachment" "manager_attach_elasticloadbalancing_policy" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = aws_iam_policy.kubernetes_ec2_manager_elasticloadbalancing_policy.arn
}

# manager autoscaling actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_autoscaling_access" {
  statement {
    sid       = "AllowAutoScalingManagementActions"
    effect    = "Allow"
    actions   = var.autoscaling_allowed_actions
    resources = ["*"]
  }
}

# manager autoscaling policy
resource "aws_iam_policy" "kubernetes_ec2_manager_autoscaling_policy" {
  name        = "kubernetes-ec2-creator-autoscaling-policy"
  description = "Policy allowing kubernetes-ec2-manager to manage autoscaling resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_autoscaling_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach manager autoscaling policy
resource "aws_iam_role_policy_attachment" "manager_attach_autoscaling_policy" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = aws_iam_policy.kubernetes_ec2_manager_autoscaling_policy.arn
}

# manager iam actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_iam_access" {
  statement {
    sid       = "AllowIAMManagementActions"
    effect    = "Allow"
    actions   = var.iam_allowed_actions
    resources = ["*"]
  }
}

# manager iam policy
resource "aws_iam_policy" "kubernetes_ec2_manager_iam_policy" {
  name        = "kubernetes-ec2-manager-iam-policy"
  description = "Policy allowing kubernetes-ec2-manager to manage iam resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_iam_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach manager iam policy
resource "aws_iam_role_policy_attachment" "manager_attach_iam_policy" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = aws_iam_policy.kubernetes_ec2_manager_iam_policy.arn
}

# manager ecr actions
data "aws_iam_policy_document" "kubernetes_ec2_manager_ecr_access" {
  statement {
    sid       = "AllowECRManagementActions"
    effect    = "Allow"
    actions   = var.iam_allowed_actions
    resources = ["*"]
  }
}

# manager ecr policy
resource "aws_iam_policy" "kubernetes_ec2_manager_ecr_policy" {
  name        = "kubernetes-ec2-manager-ecr-policy"
  description = "Policy allowing kubernetes-ec2-manager to manage ecr resources"
  policy      = data.aws_iam_policy_document.kubernetes_ec2_manager_ecr_access.json

  tags = {
    ManagedBy = "${data.aws_caller_identity.current.arn}"
  }
}

# attach manager ecr policy
resource "aws_iam_role_policy_attachment" "manager_attach_ecr_policy" {
  role       = aws_iam_role.kubernetes_ec2_manager.name
  policy_arn = aws_iam_policy.kubernetes_ec2_manager_ecr_policy.arn
}

