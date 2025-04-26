terraform {
  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "bootstrap/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tfaws-dev-lock-backend"
    encrypt        = true
  }
}
