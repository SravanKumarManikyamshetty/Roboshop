data "aws_ssm_parameter" "vpc_id"{
  name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_security_group" "sgs_id" {
  count = length(var.sg_names)
  id = aws_security_group.sgs[count.index].id
}