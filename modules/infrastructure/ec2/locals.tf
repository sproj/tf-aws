locals {
  ec2_permissions = {
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
}
