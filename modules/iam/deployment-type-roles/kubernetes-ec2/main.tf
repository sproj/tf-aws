module "creator" {
  source = "./creator"

  bootstrapper_role_name = var.bootstrapper_role_name
}

module "manager" {
  source = "./manager"

  bootstrapper_role_name = var.bootstrapper_role_name
}

module "reader" {
  source = "./reader"

  bootstrapper_role_name = var.bootstrapper_role_name
}
