module "kubernetes_ec2" {
  source = "../../terraform/modules/deployment-types/kubernetes-ec2"

  aws_region         = "eu-west-1"
  name_prefix        = "dev-k8s"
  vpc_cidr           = "10.0.0.0/16"
  public_subnet_cidr = "10.0.1.0/24"
}
