resource "aws_ssm_parameter" "alb_arn" {
  name  = "/${var.project}/${var.environment}/backend_alb_arn"
  type  = "String"
  value = aws_lb.backend_alb.arn
}