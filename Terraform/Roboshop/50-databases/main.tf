module "database" {
  source = "../../Common/DATABASE"
  project = local.project
  environment = local.environment
}