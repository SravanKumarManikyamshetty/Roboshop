data "aws_ssm_parameter" "mongodb_id"{
    name = "/${var.project}/${var.environment}/mongodb"
}
data "aws_ssm_parameter" "mysql_id"{
    name = "/${var.project}/${var.environment}/mysql"
}
data "aws_ssm_parameter" "redditmq_id"{
    name = "/${var.project}/${var.environment}/redditmq"
}
data "aws_ssm_parameter" "redis_id"{
    name = "/${var.project}/${var.environment}/redis"
}
data "aws_ssm_parameter" "catalogue_id"{
    name = "/${var.project}/${var.environment}/catalogue"
}
data "aws_ssm_parameter" "user_id"{
    name = "/${var.project}/${var.environment}/user"
}
data "aws_ssm_parameter" "cart_id"{
    name = "/${var.project}/${var.environment}/cart"
}
data "aws_ssm_parameter" "payment_id"{
    name = "/${var.project}/${var.environment}/payment"
}
data "aws_ssm_parameter" "shipping_id"{
    name = "/${var.project}/${var.environment}/shipping"
}
data "aws_ssm_parameter" "backend-alb_id"{
    name = "/${var.project}/${var.environment}/backend-alb"
}
data "aws_ssm_parameter" "frontend_id"{
    name = "/${var.project}/${var.environment}/frontend"
}
data "aws_ssm_parameter" "frontend-alb_id"{
    name = "/${var.project}/${var.environment}/frontend-alb"
}
data "aws_ssm_parameter" "bastion_id"{
    name = "/${var.project}/${var.environment}/bastion"
}
data "aws_ssm_parameter" "vpc_id"{
  name = "/${var.project}/${var.environment}/vpc_id"
}

data "http" "my_public_ip" {
  url = "https://ipv4.icanhazip.com"
}
