#Mongodb in private subnet
resource "aws_instance" "Mongodb" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  subnet_id                   = split(",",data.aws_ssm_parameter.database_subnet_id.value)[0]
  vpc_security_group_ids      = [data.aws_ssm_parameter.mongodb_sg_id.value]
  user_data = templatefile("${path.module}/mongo.sh.tftpl", {

  })
  tags = {
    Name = "${var.project}-${var.environment}-Mongodb"
  }
}

#redis in private subnet
resource "aws_instance" "redis" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  subnet_id                   = split(",",data.aws_ssm_parameter.database_subnet_id.value)[0]
  vpc_security_group_ids      = [data.aws_ssm_parameter.redis_sg_id.value]
  user_data = templatefile("${path.module}/redis.sh.tftpl", {
    
  })
  tags = {
    Name = "${var.project}-${var.environment}-redis"
  }
}

#Mysql in private subnet
resource "aws_instance" "Mysql" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  subnet_id                   = split(",",data.aws_ssm_parameter.database_subnet_id.value)[0]
  vpc_security_group_ids      = [data.aws_ssm_parameter.mysql_sg_id.value]
  user_data = templatefile("${path.module}/mysql.sh.tftpl", {
    
  })
  tags = {
    Name = "${var.project}-${var.environment}-Mysql"
  }
}

#redditmq in private subnet
resource "aws_instance" "redditmq" {
  ami           = data.aws_ami.joindevops.id
  instance_type = "t3.micro"
  subnet_id                   = split(",",data.aws_ssm_parameter.database_subnet_id.value)[0]
  vpc_security_group_ids      = [data.aws_ssm_parameter.redditmq_sg_id.value]
  user_data = templatefile("${path.module}/redditmq.sh.tftpl", {
    
  })
  tags = {
    Name = "${var.project}-${var.environment}-redditmq"
  }
}