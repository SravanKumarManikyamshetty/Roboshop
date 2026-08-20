module "create_vpc" {
    source = "../../Common/VPC"
    project = local.project
    environment = local.environment
}