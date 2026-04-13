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

data "terraform_remote_state" "dns" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "bootstrap/dns/terraform.tfstate"
    region  = "eu-west-1"
    profile = "super-user"
  }
}

resource "aws_route53_record" "route_52_alias_record" {
  type    = "A"
  name    = var.the_domain_name
  zone_id = data.terraform_remote_state.dns.outputs.zone_id
  alias {
    name                   = var.nlb_dns_name
    evaluate_target_health = true
    zone_id                = var.nlb_zone_id
  }
}
