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
  source = "../../../permissions/networking"
}
module "ec2" {
  source = "../../../permissions/ec2"
}
module "elasticloadbalancing" {
  source = "../../../permissions/elasticloadbalancing"
}
module "autoscaling" {
  source = "../../../permissions/autoscaling"
}

module "iam" {
  source = "../../../permissions/iam"
}

module "ecr" {
  source = "../../../permissions/ecr"
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
  role_name                      = "kubernetes-ec2-creator"
  policy_name                    = "kubernetes-ec2-creator-policy"
  actions                        = local.creator_permissions
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
  bootstrapper_role_name         = var.bootstrapper_role_name
}

module "manager" {
  source                         = "./role"
  role_name                      = "kubernetes-ec2-manager"
  policy_name                    = "kubernetes-ec2-manager-policy"
  actions                        = local.manager_permissions
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
  bootstrapper_role_name         = var.bootstrapper_role_name
}

module "reader" {
  source                         = "./role"
  role_name                      = "kubernetes-ec2-reader"
  policy_name                    = "kubernetes-ec2-reader-policy"
  actions                        = local.reader_permissions
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_readonly_access_policy_arn
  bootstrapper_role_name         = var.bootstrapper_role_name
}
