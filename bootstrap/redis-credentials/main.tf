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

resource "random_password" "redis_superuser_password" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_ssm_parameter" "redis_superuser_user" {
  name  = "/${var.env}/${var.name_prefix}/redis/username"
  type  = "SecureString"
  value = "redis"
}

resource "aws_ssm_parameter" "redis_superuser_password" {
  name  = "/${var.env}/${var.name_prefix}/redis/password"
  type  = "SecureString"
  value = random_password.redis_superuser_password.result
}
