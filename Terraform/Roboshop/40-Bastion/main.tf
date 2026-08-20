module "sgs" {
    source = "../../Common/Bastion"
    project = local.project
    environment = local.environment
}