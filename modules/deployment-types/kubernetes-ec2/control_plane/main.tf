locals {
  k8s_user_data = templatefile("${path.module}/scripts/initialize-k8s-master.sh", {
    pod_network_cidr   = var.pod_network_cidr
    service_cidr       = var.service_cidr
    kubernetes_version = var.kubernetes_version
    cni_version        = var.cni_version
    private_ip         = "$(hostname -I | awk '{print $1}')"
    flannel_manifest   = file("${path.module}/files/kube-flannel-${var.cni_version}.yml")
  })
}

module "master_instance" {
  source               = "../../../infrastructure/ec2-instance"
  ami_id               = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.public_subnet_ids[0]
  security_group_ids   = var.security_group_ids
  iam_instance_profile = var.iam_instance_profile
  key_name             = var.key_name
  name                 = "${var.name_prefix}-master"
  tags                 = var.tags

  user_data = base64encode(local.k8s_user_data)
}
