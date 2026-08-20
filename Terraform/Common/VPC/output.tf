output "vpc_id" {
    value = data.aws_vpc.vpc_id
}

output "public_subnet_ids" {
    value = aws_subnet.public_subnet
}

output "private_subnet_ids" {
    value = aws_subnet.private_subnet
}

output "database_subnet_ids" {
    value = aws_subnet.database_subnet
}