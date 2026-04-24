# Install EBS CSI driver
data "aws_ssm_parameter" "ebs_csi_ec2_access_key_id" {
  name            = "/${var.env}/${var.name_prefix}/ebs-csi-ec2-access-key-id"
  with_decryption = true
}

data "aws_ssm_parameter" "ebs_csi_ec2_secret_access_key" {
  name            = "/${var.env}/${var.name_prefix}/ebs-csi-ec2-secret-access-key"
  with_decryption = true
}

resource "kubernetes_secret" "ebs_csi_driver_credentials" {
  data = {
    "key_id" : data.aws_ssm_parameter.ebs_csi_ec2_access_key_id.value,
    "access_key" : data.aws_ssm_parameter.ebs_csi_ec2_secret_access_key.value
  }

  metadata {
    namespace = "kube-system"
    name      = "aws-secret"
  }
}

resource "helm_release" "ebs_csi_driver" {
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  name       = "aws-ebs-csi-driver"
  depends_on = [kubernetes_secret.ebs_csi_driver_credentials]
  values     = [templatefile("${path.module}/ebs-csi/ebs-csi-values.yaml", {
    "region": var.aws_region
  })]
}

resource "kubernetes_storage_class_v1" "ebs_csi_storageclass" {
  depends_on = [helm_release.ebs_csi_driver]
  metadata {
    name = "ebs-sc"
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    "type" : "gp3"
  }
}
