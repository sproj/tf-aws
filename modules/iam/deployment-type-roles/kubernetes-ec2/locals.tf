locals {
  kubernetes_ec2_allowed_actions = {
    networking = {
      creator = [
        "ec2:CreateVpc",
        "ec2:DeleteVpc",
        "ec2:DescribeVpcs",
        "ec2:CreateSubnet",
        "ec2:DeleteSubnet",
        "ec2:DescribeSubnets",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:AttachInternetGateway",
        "ec2:DetachInternetGateway",
        "ec2:DescribeInternetGateways",
        "ec2:CreateRouteTable",
        "ec2:DeleteRouteTable",
        "ec2:AssociateRouteTable",
        "ec2:DisassociateRouteTable",
        "ec2:DescribeRouteTables",
        "ec2:CreateRoute",
        "ec2:ReplaceRoute",
        "ec2:DeleteRoute",
        "ec2:DescribeRouteTables",
        "ec2:ModifyVpcAttribute"
      ]
      manager = [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeRouteTables",
        "ec2:ModifyVpcAttribute"
      ]
      reader = [
        "ec2:DescribeVpcs",
        "ec2:DescribeSubnets",
        "ec2:DescribeInternetGateways",
        "ec2:DescribeRouteTables"
      ]
    }

    ec2 = {
      creator = [
        "ec2:RunInstances",
        "ec2:TerminateInstances",
        "ec2:CreateSecurityGroup",
        "ec2:DeleteSecurityGroup",
        "ec2:CreateRoute",
        "ec2:DeleteRoute",
        "ec2:CreateInternetGateway",
        "ec2:DeleteInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:DeleteNatGateway",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:AllocateAddress",
        "ec2:ReleaseAddress",
        "ec2:CreateVpc",
      ]
      manager = [
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyVolume",
      ]
      reader = [
        "ec2:Describe*",
      ]
    }

    elasticloadbalancing = {
      creator = [
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:DeleteLoadBalancer",
      ]
      manager = [
        "elasticloadbalancing:ConfigureHealthCheck",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
      ]
      reader = [
        "elasticloadbalancing:Describe*",
      ]
    }

    autoscaling = {
      creator = [
        "autoscaling:CreateAutoScalingGroup",
        "autoscaling:DeleteAutoScalingGroup",
      ]
      manager = [
        "autoscaling:UpdateAutoScalingGroup",
      ]
      reader = [
        "autoscaling:Describe*",
      ]
    }

    iam = {
      creator = [
        "iam:PassRole"
      ]
      manager = [
        "iam:PassRole"
      ]
      reader = [
        "iam:Get*",
        "iam:List*",
      ]
    }

    ecr = {
      creator = []
      manager = []
      reader = [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage"
      ]
    }
  }
}
