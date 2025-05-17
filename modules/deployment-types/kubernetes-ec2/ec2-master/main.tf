resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name

  user_data = base64encode(templatefile("${path.module}/scripts/initialize-k8s-master.sh", {
    pod_network_cidr   = var.pod_network_cidr
    service_cidr       = var.service_cidr
    kubernetes_version = var.kubernetes_version
    cni_version        = var.cni_version
    private_ip         = "$(hostname -I | awk '{print $1}')" # This will be evaluated on the instance
  }))

  tags = merge(var.tags, { Name = "${var.name_prefix}-master" })
}
