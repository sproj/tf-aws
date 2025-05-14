data "terraform_remote_state" "state_backend" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "bootstrap/terraform.tfstate"
    region  = "eu-west-1"
    profile = "infrastructure-manager"
  }
}

module "networking" {
  source = "../../../infrastructure/networking"
}
module "ec2" {
  source = "../../../infrastructure/ec2"
}
module "elasticloadbalancing" {
  source = "../../../infrastructure/elasticloadbalancing"
}
module "autoscaling" {
  source = "../../../infrastructure/autoscaling"
}

module "iam" {
  source = "../../../infrastructure/iam"
}

module "ecr" {
  source = "../../../infrastructure/ecr"
}

locals {
  creator_permissions = concat(
    module.networking.creator_permissions,
    module.ec2.creator_permissions,
    module.elasticloadbalancing.creator_permissions,
    module.autoscaling.creator_permissions,
    module.iam.creator_permissions,
    module.ecr.creator_permissions
    # add more as needed
  )

  manager_permissions = concat(
    module.networking.manager_permissions,
    module.ec2.manager_permissions,
    module.elasticloadbalancing.manager_permissions,
    module.autoscaling.manager_permissions,
    module.iam.manager_permissions,
    module.ecr.manager_permissions
  )

  reader_permissions = concat(
    module.networking.reader_permissions,
    module.ec2.reader_permissions,
    module.elasticloadbalancing.reader_permissions,
    module.autoscaling.reader_permissions,
    module.iam.reader_permissions,
    module.ecr.reader_permissions
  )
}

module "creator" {
  source = "./creator"

  bootstrapper_role_name               = var.bootstrapper_role_name
  backend_full_access_policy_arn       = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
  networking_allowed_actions           = local.kubernetes_ec2_allowed_actions.networking.creator
  ec2_allowed_actions                  = local.kubernetes_ec2_allowed_actions.ec2.creator
  elasticloadbalancing_allowed_actions = local.kubernetes_ec2_allowed_actions.elasticloadbalancing.creator
  autoscaling_allowed_actions          = local.kubernetes_ec2_allowed_actions.autoscaling.creator
  iam_allowed_actions                  = local.kubernetes_ec2_allowed_actions.iam.creator
  ecr_allowed_actions                  = local.kubernetes_ec2_allowed_actions.ecr.creator
}

module "manager" {
  source = "./manager"

  bootstrapper_role_name               = var.bootstrapper_role_name
  backend_full_access_policy_arn       = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
  networking_allowed_actions           = local.kubernetes_ec2_allowed_actions.networking.manager
  ec2_allowed_actions                  = local.kubernetes_ec2_allowed_actions.ec2.manager
  elasticloadbalancing_allowed_actions = local.kubernetes_ec2_allowed_actions.elasticloadbalancing.manager
  autoscaling_allowed_actions          = local.kubernetes_ec2_allowed_actions.autoscaling.manager
  iam_allowed_actions                  = local.kubernetes_ec2_allowed_actions.iam.manager
  ecr_allowed_actions                  = local.kubernetes_ec2_allowed_actions.ecr.manager
}

module "reader" {
  source = "./reader"

  bootstrapper_role_name               = var.bootstrapper_role_name
  backend_readonly_access_policy_arn   = data.terraform_remote_state.state_backend.outputs.terraform_backend_readonly_access_policy_arn
  networking_allowed_actions           = local.kubernetes_ec2_allowed_actions.networking.reader
  ec2_allowed_actions                  = local.kubernetes_ec2_allowed_actions.ec2.reader
  elasticloadbalancing_allowed_actions = local.kubernetes_ec2_allowed_actions.elasticloadbalancing.reader
  autoscaling_allowed_actions          = local.kubernetes_ec2_allowed_actions.autoscaling.reader
  iam_allowed_actions                  = local.kubernetes_ec2_allowed_actions.iam.reader
  ecr_allowed_actions                  = local.kubernetes_ec2_allowed_actions.ecr.reader
}
