data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ebs_csi" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateVolume",
      "ec2:DeleteVolume",
      "ec2:AttachVolume",
      "ec2:DetachVolume",
      "ec2:ModifyVolume",
      "ec2:DescribeVolumes",
      "ec2:DescribeVolumeStatus",
      "ec2:DescribeInstances",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeSnapshots",
      "ec2:CreateSnapshot",
      "ec2:DeleteSnapshot",
      "ec2:CreateTags",
      "ec2:DescribeTags",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ebs_csi" {
  name        = "${var.name_prefix}-ebs-csi-policy"
  description = "Permissions for the EBS CSI driver running on EC2 nodes"
  policy      = data.aws_iam_policy_document.ebs_csi.json

  tags = {
    ManagedBy = data.aws_caller_identity.current.arn
  }
}
