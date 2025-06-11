# ### network.tf ###

resource "aws_vpc" "ob_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "ob-vpc" }
}

resource "aws_subnet" "ob_public_subnet_1" {
  vpc_id                  = aws_vpc.ob_vpc.id
  cidr_block              = var.public_subnet_1_cidr
  availability_zone       = var.aws_az_1
  map_public_ip_on_launch = true
  tags = { Name = "ob-public-subnet-1" }
}

resource "aws_subnet" "ob_public_subnet_2" {
  vpc_id                  = aws_vpc.ob_vpc.id
  cidr_block              = var.public_subnet_2_cidr
  availability_zone       = var.aws_az_2
  map_public_ip_on_launch = true
  tags = { Name = "ob-public-subnet-2" }
}

resource "aws_subnet" "ob_private_subnet_1" {
  vpc_id            = aws_vpc.ob_vpc.id
  cidr_block        = var.private_subnet_1_cidr
  availability_zone = var.aws_az_1
  tags = { Name = "ob-private-subnet-1" }
}

resource "aws_subnet" "ob_private_subnet_2" {
  vpc_id            = aws_vpc.ob_vpc.id
  cidr_block        = var.private_subnet_2_cidr
  availability_zone = var.aws_az_2
  tags = { Name = "ob-private-subnet-2" }
}

resource "aws_internet_gateway" "ob_igw" {
  vpc_id = aws_vpc.ob_vpc.id
  tags = { Name = "ob-igw" }
}

resource "aws_eip" "ob_nat_eip" {
  domain = "vpc"
  tags   = { Name = "ob-nat-eip" }
}

resource "aws_nat_gateway" "ob_nat_gw" {
  allocation_id = aws_eip.ob_nat_eip.id
  subnet_id     = aws_subnet.ob_public_subnet_1.id
  tags          = { Name = "ob-nat-gw" }
  depends_on    = [aws_internet_gateway.ob_igw]
}

resource "aws_route_table" "ob_public_rt" {
  vpc_id = aws_vpc.ob_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ob_igw.id
  }
  tags = { Name = "ob-public-rt" }
}

resource "aws_route_table" "ob_private_rt" {
  vpc_id = aws_vpc.ob_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ob_nat_gw.id
  }
  tags = { Name = "ob-private-rt" }
}

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.ob_public_subnet_1.id
  route_table_id = aws_route_table.ob_public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.ob_public_subnet_2.id
  route_table_id = aws_route_table.ob_public_rt.id
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.ob_private_subnet_1.id
  route_table_id = aws_route_table.ob_private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.ob_private_subnet_2.id
  route_table_id = aws_route_table.ob_private_rt.id
}