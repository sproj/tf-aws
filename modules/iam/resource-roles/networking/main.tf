# Networking Resource Roles Module
# This module creates IAM roles and policies for networking resource management

# Networking Creator Role - For provisioning VPCs, subnets, etc.
resource "aws_iam_role" "networking_creator" {
  name = "${var.name_prefix}-networking-creator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_role_arns
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-networking-creator-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Networking Manager Role - For managing existing networking resources
resource "aws_iam_role" "networking_manager" {
  name = "${var.name_prefix}-networking-manager-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_role_arns
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-networking-manager-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Networking Reader Role - For read-only access to networking resources
resource "aws_iam_role" "networking_reader" {
  name = "${var.name_prefix}-networking-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = var.trusted_role_arns
        }
      }
    ]
  })

  tags = {
    Name        = "${var.name_prefix}-networking-reader-role"
    Environment = var.environment
    Terraform   = "true"
  }
}

# Networking Creator Policy - Permissions to create VPCs, subnets, etc.
resource "aws_iam_policy" "networking_creator_policy" {
  name        = "${var.name_prefix}-networking-creator-policy"
  description = "Policy for creating and configuring networking resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # VPC
          "ec2:CreateVpc",
          "ec2:CreateVpcEndpoint",
          "ec2:CreateVpcPeeringConnection",
          "ec2:AcceptVpcPeeringConnection",

          # Subnet
          "ec2:CreateSubnet",
          "ec2:ModifySubnetAttribute",

          # Route Tables
          "ec2:CreateRouteTable",
          "ec2:CreateRoute",
          "ec2:AssociateRouteTable",

          # Internet Gateway
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",

          # NAT Gateway
          "ec2:CreateNatGateway",
          "ec2:AllocateAddress", # For Elastic IPs used by NAT Gateways

          # Security Groups
          "ec2:CreateSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",

          # Network ACLs
          "ec2:CreateNetworkAcl",
          "ec2:CreateNetworkAclEntry",

          # Elastic Load Balancing
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroupAttributes",

          # Transit Gateway
          "ec2:CreateTransitGateway",
          "ec2:CreateTransitGatewayRoute",
          "ec2:CreateTransitGatewayRouteTable",
          "ec2:CreateTransitGatewayVpcAttachment",

          # VPN and Direct Connect
          "ec2:CreateVpnGateway",
          "ec2:AttachVpnGateway",
          "ec2:CreateVpnConnection",
          "ec2:CreateCustomerGateway",
          "directconnect:CreateConnection",
          "directconnect:CreatePrivateVirtualInterface",
          "directconnect:CreatePublicVirtualInterface",

          # General
          "ec2:CreateTags",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeTransitGatewayRouteTables",
          "ec2:DescribeVpnGateways",
          "ec2:DescribeVpnConnections",
          "ec2:DescribeCustomerGateways",
          "ec2:DescribeAddresses",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "directconnect:DescribeConnections",
          "directconnect:DescribeVirtualInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

# Networking Manager Policy - Permissions to manage existing networking resources
resource "aws_iam_policy" "networking_manager_policy" {
  name        = "${var.name_prefix}-networking-manager-policy"
  description = "Policy for managing existing networking resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # VPC
          "ec2:ModifyVpcAttribute",
          "ec2:ModifyVpcEndpoint",
          "ec2:ModifyVpcPeeringConnection",

          # Subnet
          "ec2:ModifySubnetAttribute",

          # Route Tables
          "ec2:ReplaceRoute",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:DisassociateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:DeleteRoute",

          # Internet Gateway
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",

          # NAT Gateway
          "ec2:DeleteNatGateway",
          "ec2:ReleaseAddress",

          # Security Groups
          "ec2:UpdateSecurityGroupRuleDescriptionsIngress",
          "ec2:UpdateSecurityGroupRuleDescriptionsEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:DeleteSecurityGroup",

          # Network ACLs
          "ec2:ReplaceNetworkAclAssociation",
          "ec2:ReplaceNetworkAclEntry",
          "ec2:DeleteNetworkAcl",
          "ec2:DeleteNetworkAclEntry",

          # Elastic Load Balancing
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:ModifyLoadBalancer",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyListener",

          # Transit Gateway
          "ec2:DeleteTransitGateway",
          "ec2:DeleteTransitGatewayRoute",
          "ec2:DeleteTransitGatewayRouteTable",
          "ec2:DeleteTransitGatewayVpcAttachment",
          "ec2:ModifyTransitGatewayVpcAttachment",

          # VPN and Direct Connect
          "ec2:DetachVpnGateway",
          "ec2:DeleteVpnGateway",
          "ec2:DeleteVpnConnection",
          "ec2:DeleteCustomerGateway",
          "directconnect:DeleteConnection",
          "directconnect:DeleteVirtualInterface",

          # General
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeTransitGatewayRouteTables",
          "ec2:DescribeVpnGateways",
          "ec2:DescribeVpnConnections",
          "ec2:DescribeCustomerGateways",
          "ec2:DescribeAddresses",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "directconnect:DescribeConnections",
          "directconnect:DescribeVirtualInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

# Networking Reader Policy - Read-only access to networking resources
resource "aws_iam_policy" "networking_reader_policy" {
  name        = "${var.name_prefix}-networking-reader-policy"
  description = "Policy for read-only access to networking resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeRouteTables",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcPeeringConnections",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeTransitGatewayAttachments",
          "ec2:DescribeTransitGatewayRouteTables",
          "ec2:DescribeVpnGateways",
          "ec2:DescribeVpnConnections",
          "ec2:DescribeCustomerGateways",
          "ec2:DescribeAddresses",
          "ec2:DescribeNetworkInterfaces",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeTargetHealth",
          "directconnect:DescribeConnections",
          "directconnect:DescribeVirtualInterfaces"
        ]
        Resource = "*"
      }
    ]
  })
}

# Additional policy for Kubernetes specific networking requirements
resource "aws_iam_policy" "kubernetes_networking_policy" {
  count       = var.enable_kubernetes_networking ? 1 : 0
  name        = "${var.name_prefix}-kubernetes-networking-policy"
  description = "Policy for Kubernetes specific networking requirements"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # For Kubernetes load balancer controller
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeListenerCertificates",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeSSLPolicies",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",

          # For CNI plugins
          "ec2:AssignPrivateIpAddresses",
          "ec2:AttachNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeVpcs",
          "ec2:DetachNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:UnassignPrivateIpAddresses"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "networking_creator_policy_attachment" {
  role       = aws_iam_role.networking_creator.name
  policy_arn = aws_iam_policy.networking_creator_policy.arn
}

resource "aws_iam_role_policy_attachment" "networking_manager_policy_attachment" {
  role       = aws_iam_role.networking_manager.name
  policy_arn = aws_iam_policy.networking_manager_policy.arn
}

resource "aws_iam_role_policy_attachment" "networking_reader_policy_attachment" {
  role       = aws_iam_role.networking_reader.name
  policy_arn = aws_iam_policy.networking_reader_policy.arn
}

# Attach Kubernetes networking policy if enabled
resource "aws_iam_role_policy_attachment" "creator_kubernetes_networking_attachment" {
  count      = var.enable_kubernetes_networking ? 1 : 0
  role       = aws_iam_role.networking_creator.name
  policy_arn = aws_iam_policy.kubernetes_networking_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "manager_kubernetes_networking_attachment" {
  count      = var.enable_kubernetes_networking ? 1 : 0
  role       = aws_iam_role.networking_manager.name
  policy_arn = aws_iam_policy.kubernetes_networking_policy[0].arn
}
