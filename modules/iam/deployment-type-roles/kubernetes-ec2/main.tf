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
  source                         = "./role"
  role_name                      = "k8s-ec2-creator"
  policy_name                    = "k8s-ec2-creator-policy"
  actions                        = local.creator_permissions
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
  bootstrapper_role_name         = var.bootstrapper_role_name
}

module "manager" {
  source                         = "./role"
  role_name                      = "k8s-ec2-manager"
  policy_name                    = "k8s-ec2-manager-policy"
  actions                        = local.manager_permissions
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
  bootstrapper_role_name         = var.bootstrapper_role_name
}

module "reader" {
  source                         = "./role"
  role_name                      = "k8s-ec2-reader"
  policy_name                    = "k8s-ec2-reader-policy"
  actions                        = local.reader_permissions
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_readonly_access_policy_arn
  bootstrapper_role_name         = var.bootstrapper_role_name
}

# ###
# module "creator" {
#   source = "./creator"

#   bootstrapper_role_name         = var.bootstrapper_role_name
#   backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
#   permitted_actions              = local.creator_permissions
# }

# module "manager" {
#   source = "./manager"

#   bootstrapper_role_name         = var.bootstrapper_role_name
#   backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
#   permitted_actions              = local.manager_permissions
# }

# module "reader" {
#   source = "./reader"

#   bootstrapper_role_name             = var.bootstrapper_role_name
#   backend_readonly_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_readonly_access_policy_arn
#   permitted_actions                  = local.reader_permissions
# }
