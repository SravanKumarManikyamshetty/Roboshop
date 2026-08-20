
# create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(var.vpc_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}-vpc"
  })
}

#create Internet GateWay
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.gw_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}-gw"
  })
}

# create 2 public subnets in 2 AZ with auto public ip asign.
resource "aws_subnet" "public_subnet" {
    count = length(var.public_ip_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.public_ip_cidrs[count.index]
    availability_zone = local.az_zone_name[count.index] #us-east-1a
    map_public_ip_on_launch = true

  tags = merge(var.public_subnet_tags,local.common_tags,{
    Name = "${var.project}-${var.environment}-public-${split("-",local.az_zone_name[count.index])[2]}"
  })
}

# create 2 private subnets in 2 AZ without public ip
resource "aws_subnet" "private_subnet" {
    count = length(var.private_ip_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.private_ip_cidrs[count.index]
    availability_zone = local.az_zone_name[count.index] #us-east-1a
    map_public_ip_on_launch = false

  tags = merge(var.private_subnet_tags,local.common_tags,{
    Name = "${var.project}-${var.environment}-private-${split("-",local.az_zone_name[count.index])[2]}"
  })
}

# create 2 database subnets in 2 AZ without public ip
resource "aws_subnet" "database_subnet" {
    count = length(var.database_ip_cidrs)
    vpc_id     = aws_vpc.main.id
    cidr_block = var.database_ip_cidrs[count.index]
    availability_zone = local.az_zone_name[count.index] #us-east-1a
    map_public_ip_on_launch = false

  tags = merge(var.database_subnet_tags,local.common_tags,{
    Name = "${var.project}-${var.environment}-database-${split("-",local.az_zone_name[count.index])[2]}"
  })
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.public_route_table_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}-public"
  })
}

# Create Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.private_route_table_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}-private"
  })
}

# Create databse Route Table
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.database_route_table_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}-Database"
  })
}

# Assign subnet association to Subnets


resource "aws_route_table_association" "public" {
    count = length(var.public_ip_cidrs)
    subnet_id      = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.public.id 
}
resource "aws_route_table_association" "private" {
    count = length(var.private_ip_cidrs)
    subnet_id      = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.private.id 
}
resource "aws_route_table_association" "database" {
    count = length(var.public_ip_cidrs)
    subnet_id      = aws_subnet.database_subnet[count.index].id
    route_table_id = aws_route_table.database.id 
}

# Allocate the Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags = merge(var.eip_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}-eip"
  }) 
  # Recommended for production to prevent accidental deletion
  lifecycle {
    prevent_destroy = false
  }
}

# Create the NAT Gateway and associate the EIP
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.gw]
  tags = merge(var.nat_tags,local.common_tags,
  {
    Name = "${var.project}-${var.environment}-nat"
  })
}   

# Routes to Internet
resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = var.destination_ip
    gateway_id = aws_internet_gateway.gw.id
}
resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = var.destination_ip
    gateway_id = aws_nat_gateway.main.id
}
resource "aws_route" "databse" {
    route_table_id = aws_route_table.database.id
     destination_cidr_block = var.destination_ip
     gateway_id = aws_nat_gateway.main.id
}