resource "aws_ssm_parameter" "vpc_id" {
  name        = "/${var.project}/${var.environment}/vpc_id"
  type        = "String"
  value       = data.aws_vpc.vpc_id.id
  description = "VPC_ID of ${var.project}"
}   
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/${var.project}/${var.environment}/public_subnet_ids"
  type  = "String"
  value = join(",",aws_subnet.public_subnet[*].id)
  overwrite = true
}

resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/${var.project}/${var.environment}/private_subnet_ids"
  type  = "String"
  value = join(",", aws_subnet.private_subnet[*].id)
  overwrite = true
}

resource "aws_ssm_parameter" "database_subnet_ids" {
  name  = "/${var.project}/${var.environment}/database_subnet_ids"
  type  = "String"
  value = join(",", aws_subnet.database_subnet[*].id)
  overwrite = true
}