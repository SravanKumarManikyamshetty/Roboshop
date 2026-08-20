resource "aws_lb" "frontend_alb" {
  name = "${var.project}-${var.environment}-frontend_alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.frontend_alb_sg.id]
  subnets            = split(",",data.aws_ssm_parameter.public_subnet_ids)[0]

  enable_deletion_protection = false

  tags = {
    name = "${var.project}-${var.environment}-frontend_alb"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_ssm_parameter.acm_certificate.value
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}