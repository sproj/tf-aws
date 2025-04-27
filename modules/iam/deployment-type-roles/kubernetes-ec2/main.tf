# IAM roles for Kubernetes on EC2 deployment type

# EC2 instance role for Kubernetes worker nodes
resource "aws_iam_role" "kubernetes_worker_node" {
  name = "${var.name_prefix}-k8s-worker-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-k8s-worker-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# IAM instance profile for the Kubernetes worker nodes
resource "aws_iam_instance_profile" "kubernetes_worker_profile" {
  name = "${var.name_prefix}-k8s-worker-profile"
  role = aws_iam_role.kubernetes_worker_node.name
}

# Policies for Kubernetes worker nodes

# Basic EC2 permissions
resource "aws_iam_policy" "kubernetes_ec2_policy" {
  name        = "${var.name_prefix}-k8s-ec2-policy"
  description = "Policy for Kubernetes EC2 instances"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeRegions",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:CreateSecurityGroup",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:ModifyInstanceAttribute",
          "ec2:ModifyVolume",
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateRoute",
          "ec2:DeleteRoute",
          "ec2:DeleteSecurityGroup",
          "ec2:DeleteVolume",
          "ec2:DetachVolume",
          "ec2:RevokeSecurityGroupIngress"
        ]
        Resource = "*"
      }
    ]
  })
}

# ELB permissions for Kubernetes service LoadBalancer type
resource "aws_iam_policy" "kubernetes_elb_policy" {
  name        = "${var.name_prefix}-k8s-elb-policy"
  description = "Policy for Kubernetes ELB integration"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
          "elasticloadbalancing:AttachLoadBalancerToSubnets",
          "elasticloadbalancing:ConfigureHealthCheck",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateLoadBalancerListeners",
          "elasticloadbalancing:CreateLoadBalancerPolicy",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteLoadBalancerListeners",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancerPolicies",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
          "elasticloadbalancing:SetLoadBalancerPoliciesOfListener"
        ]
        Resource = "*"
      }
    ]
  })
}

# ECR permissions for pulling container images
resource "aws_iam_policy" "kubernetes_ecr_policy" {
  name        = "${var.name_prefix}-k8s-ecr-policy"
  description = "Policy for Kubernetes ECR access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# Policy for AWS IAM Authenticator for Kubernetes
resource "aws_iam_policy" "kubernetes_iam_auth_policy" {
  name        = "${var.name_prefix}-k8s-iam-auth-policy"
  description = "Policy for AWS IAM Authenticator for Kubernetes"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:ListRoles",
          "iam:PassRole"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to Kubernetes worker role
resource "aws_iam_role_policy_attachment" "kubernetes_ec2_attachment" {
  role       = aws_iam_role.kubernetes_worker_node.name
  policy_arn = aws_iam_policy.kubernetes_ec2_policy.arn
}

resource "aws_iam_role_policy_attachment" "kubernetes_elb_attachment" {
  role       = aws_iam_role.kubernetes_worker_node.name
  policy_arn = aws_iam_policy.kubernetes_elb_policy.arn
}

resource "aws_iam_role_policy_attachment" "kubernetes_ecr_attachment" {
  role       = aws_iam_role.kubernetes_worker_node.name
  policy_arn = aws_iam_policy.kubernetes_ecr_policy.arn
}

resource "aws_iam_role_policy_attachment" "kubernetes_iam_auth_attachment" {
  role       = aws_iam_role.kubernetes_worker_node.name
  policy_arn = aws_iam_policy.kubernetes_iam_auth_policy.arn
}

# Attach AWS managed policy for SSM (for node management)
resource "aws_iam_role_policy_attachment" "kubernetes_ssm_attachment" {
  role       = aws_iam_role.kubernetes_worker_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IRSA (IAM Roles for Service Accounts) support 
# This enables pods to have specific IAM roles via service accounts
resource "aws_iam_openid_connect_provider" "kubernetes" {
  count = var.enable_irsa ? 1 : 0
  
  url = var.eks_oidc_issuer_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = var.eks_oidc_provider_thumbprint
}