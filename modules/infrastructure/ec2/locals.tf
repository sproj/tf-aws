locals {
  ec2_permissions = {
    creator = [
      "ec2:RunInstances",
      "ec2:TerminateInstances",
      "ec2:DescribeSecurityGroups",
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
      "ec2:DescribeTags",
      "ec2:AllocateAddress",
      "ec2:ReleaseAddress",
      "ec2:AssociateAddress",
      "ec2:DisassociateAddress",
      "ec2:CreateVpc",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:AuthorizeSecurityGroupEgress",
      "ec2:RevokeSecurityGroupIngress",
      "ec2:RevokeSecurityGroupEgress",
      "ec2:CreateLaunchTemplate",
      "ec2:DeleteLaunchTemplate",
      "ec2:DeleteLaunchTemplateVersions",
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:DescribeVolumes",
      "ec2:ModifyVolume",
      "ec2:Describe*"
    ]
    manager = [
      "ec2:DescribeSecurityGroups",
      "ec2:ModifyInstanceAttribute",
      "ec2:DescribeVolume",
      "ec2:ModifyVolume"
    ]
    reader = [
      "ec2:Describe*",
    ]
  }
}
