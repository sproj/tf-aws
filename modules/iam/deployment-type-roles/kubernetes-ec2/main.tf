module "creator" {
  source = "./creator"

  bootstrapper_user_name = var.bootstrapper_user_name
}

module "manager" {
  source = "./manager"

  bootstrapper_user_name = var.bootstrapper_user_name
}

module "reader" {
  source = "./reader"

  bootstrapper_user_name = var.bootstrapper_user_name
}
