data "terraform_remote_state" "state_backend" {
  backend = "s3"
  config = {
    bucket  = "tfaws-dev-state-backend"
    key     = "bootstrap/terraform.tfstate"
    region  = "eu-west-1"
    profile = "infrastructure-manager"
  }
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
