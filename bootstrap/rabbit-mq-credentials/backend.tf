terraform {
  backend "s3" {
    bucket         = "tfaws-dev-state-backend"
    key            = "bootstrap/rabbitmq-credentials/terraform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "tfaws-dev-lock-backend"
    encrypt        = true
    profile        = "super-user"
  }
}
