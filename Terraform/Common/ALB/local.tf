locals {
  private_subnet_ids = data.aws_ssm_parameter.private_subnet_id.value
}