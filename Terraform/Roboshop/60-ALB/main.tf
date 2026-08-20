module "database" {
  source = "../../Common/ALB"
  project = local.project
  environment = local.environment
}