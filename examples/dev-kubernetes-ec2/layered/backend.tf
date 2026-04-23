terraform {
  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "examples/kubernetes-ec2/layered/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tfaws-dev-lock-backend"
    profile        = "kubernetes-ec2-creator"
  }
}
