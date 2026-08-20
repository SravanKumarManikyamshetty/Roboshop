module "database" {
  source = "../../Common/Backend"
  project = local.project
  environment = local.environment
  backend_name = var.backend_name
}