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

  bootstrapper_role_name         = var.bootstrapper_role_name
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
}

module "manager" {
  source = "./manager"

  bootstrapper_role_name         = var.bootstrapper_role_name
  backend_full_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_full_access_policy_arn
}

module "reader" {
  source = "./reader"

  bootstrapper_role_name             = var.bootstrapper_role_name
  backend_readonly_access_policy_arn = data.terraform_remote_state.state_backend.outputs.terraform_backend_readonly_access_policy_arn
}
