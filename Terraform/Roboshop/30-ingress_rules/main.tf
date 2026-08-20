module "sgs" {
    source = "../../Common/Ingress_rules"
    project = local.project
    environment = local.environment
}