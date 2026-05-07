terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "super-user"
}

resource "random_password" "rabbitmq_user_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "rabbit_mq_username" {
  name  = "/${var.env}/${var.name_prefix}/rabbitmq/rabbitmq-username"
  type  = "SecureString"
  value = "rabbitmq_manager"
}

resource "aws_ssm_parameter" "rabbitmq_user_password" {
  name  = "/${var.env}/${var.name_prefix}/rabbitmq/rabbitmq-password"
  type  = "SecureString"
  value = random_password.rabbitmq_user_password.result
}
