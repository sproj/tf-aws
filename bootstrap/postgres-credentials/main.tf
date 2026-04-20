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

resource "random_password" "postgres_superuser_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "postgres_superuser_user" {
  name  = "/${var.env}/${var.name_prefix}/postgres/superuser-user"
  type  = "SecureString"
  value = "postgres"
}

resource "aws_ssm_parameter" "postgres_superuser_password" {
  name  = "/${var.env}/${var.name_prefix}/postgres/superuser-password"
  type  = "SecureString"
  value = random_password.postgres_superuser_password.result
}
