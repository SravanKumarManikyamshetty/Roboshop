resource "aws_lb" "backend_alb" {
  name               = "${var.project}-${var.environment}-backend-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.backend_alb_sg_id.value]
  subnets            = split(",", local.private_subnet_ids)

  enable_deletion_protection = false
  tags = {
     name            = "${var.project}-${var.environment}-backend-alb"
  }
}

resource "aws_lb_target_group" "test" {
  name     = "${var.project}-${var.environment}-backend-alb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_lb_listener" "http_fixed_response" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "The requested resource was not found."
      status_code  = "404"
    }
  }
}