resource "aws_instance" "backend" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  subnet_id                   = split(",",data.aws_ssm_parameter.private_subnet_ids.value)[0]
  vpc_security_group_ids      = [data.aws_ssm_parameter.catalogue_sg_id.value]
  tags = {
    Name = "${var.project}-${var.environment}-${var.backend_name}"
  }
}
resource "aws_ec2_instance_state" "backend_stop" {
  instance_id = aws_instance.backend.id
  state       = "stopped"
  depends_on = [ aws_instance.backend ]
}
resource "aws_ami_from_instance" "backend_ami" {
  name = "${var.project}-${var.environment}-${var.backend_name}-ami"
  source_instance_id = aws_instance.backend.id
  depends_on = [ aws_ec2_instance_state.backend_stop ]
  tags = {
    Name = "${var.project}-${var.environment}-${var.backend_name}-ami"
  }
}
resource "aws_launch_template" "backend" {
  name = "${var.project}-${var.environment}-${var.backend_name}"
  image_id = aws_ami_from_instance.backend_ami.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.catalogue_sg_id.value]
    tags = {
      Name = "${var.project}-${var.environment}-${var.backend_name}"
    }
}
resource "aws_lb_target_group" "backend_tg" {
  name     = "${var.project}-${var.environment}-${var.backend_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.id
    tags ={
        Name = "${var.project}-${var.environment}-${var.backend_name}-${aws_instance.backend.id}"
    }
}
resource "aws_autoscaling_group" "Auto_scaling" {
    name = "${var.project}-${var.environment}-${var.backend_name}-autoscale"
    min_size = 1
    max_size = 3
    health_check_grace_period = 200
    health_check_type         = "ELB"
    target_group_arns = [ aws_lb_target_group.backend_tg.arn ]
    desired_capacity          = 1
    vpc_zone_identifier = split(",",data.aws_ssm_parameter.private_subnet_ids.value)
    launch_template {
        id      = aws_launch_template.backend.id
        version = "$Latest"
    }
    instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  dynamic "tag" {
    for_each = merge(
      {
        Name = "${var.project}-${var.environment}-${var.backend_name}"
      },
    )
    content{
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # with in 15min autoscaling should be successful to launch instances
  timeouts {
    delete = "15m"
  }
}
resource "aws_autoscaling_policy" "catalogue" {
  autoscaling_group_name = aws_autoscaling_group.Auto_scaling.name
  name                   = "${var.project}-${var.environment}-${var.backend_name}"
  policy_type            = "TargetTrackingScaling"
  estimated_instance_warmup = 120
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 75.0
  }
}

resource "aws_lb_listener_rule" "catalogue" {
  listener_arn = data.aws_ssm_parameter.backend_alb_id.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }

  condition {
    host_header {
      values = ["catalogue.backend-alb-${var.environment}"]
    }
  }
}

