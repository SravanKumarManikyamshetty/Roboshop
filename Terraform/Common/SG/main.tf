resource "aws_security_group" "sgs" {
    count = length(var.sg_names)
    name        = "${var.project}-${var.environment}-${var.sg_names[count.index]}"
    description = "Allow TLS inbound traffic and all outbound traffic"
    vpc_id      = data.aws_ssm_parameter.vpc_id.value
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags = merge(var.sg_tags,local.common_tags,{
    Name = "${var.project}-${var.environment}-${var.sg_names[count.index]}"
  })
}