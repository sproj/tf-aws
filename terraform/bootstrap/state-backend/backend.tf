terraform {
  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "${var.env}/${var.deployment_type}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "tfaws-dev-lock-backend"
    encrypt        = true
  }
}
