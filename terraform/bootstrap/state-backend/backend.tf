terraform {
  backend "s3" {
    bucket         = "tfaws-terraform-state-123456789012" # or from output later
    key            = "${var.env}/${var.deployment_type}/terraform.tfstate"
    region         = var.aws_region
    dynamodb_table = "tfaws-terraform-locks"  # or from output later
    encrypt        = true
  }
}
