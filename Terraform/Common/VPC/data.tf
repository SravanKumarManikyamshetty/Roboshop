data "aws_availability_zones" "available" {
  state = "available"
}
data "aws_vpc" "vpc_id" {
    id = aws_vpc.main.id
}

