module "sgs" {
    source = "../../Common/SG"
    project = local.project
    environment = local.environment
}