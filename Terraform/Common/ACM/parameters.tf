resource "aws_ssm_parameter" "roboshop" {
  name  = "/${var.project}/${var.environment}/acm_certificate"
  type  = "String"
  value = aws_acm_certificate.roboshop.arn
}