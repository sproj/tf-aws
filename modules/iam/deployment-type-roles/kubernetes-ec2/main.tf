module "creator" {
  source = "./creator"

  name_prefix            = var.name_prefix
  bootstrapper_user_name = var.bootstrapper_user_name
}

module "manager" {
  source = "./manager"

  name_prefix            = var.name_prefix
  bootstrapper_user_name = var.bootstrapper_user_name
}

module "reader" {
  source = "./reader"

  name_prefix            = var.name_prefix
  bootstrapper_user_name = var.bootstrapper_user_name
}
