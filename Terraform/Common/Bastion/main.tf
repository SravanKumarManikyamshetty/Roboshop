resource "aws_instance" "web" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  subnet_id                   = split(",",data.aws_ssm_parameter.public_subnet_id.value)[0]
  vpc_security_group_ids      = [data.aws_ssm_parameter.bastion_sg_id.value]
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.Bastion_Role.name
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = 30
  }
  tags = {
    Name = "${var.project}-${var.environment}-Bastion"
  }
}

