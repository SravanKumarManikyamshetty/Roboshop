resource "aws_ssm_parameter" "parameters" {
    count = length(var.sg_names)
    name  = "/${var.project}/${var.environment}/${var.sg_names[count.index]}"
    type  = "String"
    value = data.aws_security_group.sgs_id[count.index].id
}