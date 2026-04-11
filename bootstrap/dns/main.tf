terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "infrastructure-manager"
}

resource "aws_route53_zone" "jonesalan404_dev" {
  name = "jonesalan404.dev"

  tags = {
    Environment = "${var.env}"
  }
}
