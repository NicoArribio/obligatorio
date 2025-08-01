# Creo el VPC
resource "aws_vpc" "ob-vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "ob-vpc"
  }
}

# Creo la subnet publica 1

resource "aws_subnet" "ob-public-subnet" {
  vpc_id                  = aws_vpc.ob-vpc.id
  cidr_block              = var.public_subnet
  availability_zone       = var.vpc_aws_az
  map_public_ip_on_launch = "true"
  tags = {
    Name = "terraform-ob-public-subnet"
  }
}

# Creo la subnet publica 2

resource "aws_subnet" "ob-public-subnet2" {
  vpc_id                  = aws_vpc.ob-vpc.id
  cidr_block              = var.public_subnet2
  availability_zone       = var.vpc_aws_az-2
  map_public_ip_on_launch = "true"
  tags = {
    Name = "terraform-ob-public-subnet2"
  }
}

# Creo la subnet privada 1

resource "aws_subnet" "ob-private-subnet" {
  vpc_id                  = aws_vpc.ob-vpc.id
  cidr_block              = var.private_subnet
  availability_zone       = var.vpc_aws_az
  map_public_ip_on_launch = "false"
  tags = {
    Name = "terraform-ob-private-subnet"
  }
}

# Creamos la subnet privada 2

resource "aws_subnet" "ob-private-subnet2" {
  vpc_id                  = aws_vpc.ob-vpc.id
  cidr_block              = var.private_subnet2
  availability_zone       = var.vpc_aws_az-2
  map_public_ip_on_launch = "false"
  tags = {
    Name = "terraform-ob-private-subnet2"
  }
}

# Creamos el INTERNET GATEWAY

resource "aws_internet_gateway" "ob-igw" {
  vpc_id = aws_vpc.ob-vpc.id
  tags = {
    Name = "terraform-ob-gw"
  }
}

# Creamos el NAT INTERNET GATEWAY
  # Primero creamos el Elastic IP

resource "aws_eip" "ob-nat-eip" {
  domain = "vpc"
  tags = {
    Name = "ob-nat-eip"
  }
}

  # Luego creo el MAT

resource "aws_nat_gateway" "ob-nigw" {
  allocation_id = aws_eip.ob-nat-eip.id
  subnet_id     = aws_subnet.ob-public-subnet.id
  tags = {
    Name = "ob-nigw"
  }
}


#Creo rutas de salida a internet para el IGW

resource "aws_route_table" "ob-public-route-table" {
  vpc_id = aws_vpc.ob-vpc.id

  route {
    cidr_block = "0.0.0.0/0" 
    gateway_id = aws_internet_gateway.ob-igw.id
  }

  tags = {
    Name = "ob_public_route_table_igw"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.ob-public-subnet.id # Subred pública
  route_table_id = aws_route_table.ob-public-route-table.id
}


# Creo ruta de salida a internet para el Nat Internet Gateway

resource "aws_route_table" "ob-private-route-table" {
  vpc_id = aws_vpc.ob-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ob-nigw.id
  }

  tags = {
    Name = "ob-private-route-table"
  }
}

# Creo la asociacion de la route table a una subnet pública

resource "aws_route_table_association" "ob-public_subnet_association1" {
  subnet_id      = aws_subnet.ob-public-subnet.id
  route_table_id = aws_route_table.ob-public-route-table.id
}

resource "aws_route_table_association" "ob-public_subnet_association2" {
  subnet_id      = aws_subnet.ob-public-subnet2.id
  route_table_id = aws_route_table.ob-public-route-table.id
}

# Creo la asociacion de la route table a una subnet privada

resource "aws_route_table_association" "ob-private-subnet_association" {
  subnet_id      = aws_subnet.ob-private-subnet.id
  route_table_id = aws_route_table.ob-private-route-table.id
}

resource "aws_route_table_association" "ob-private-subnet_association2" {
  subnet_id      = aws_subnet.ob-private-subnet2.id
  route_table_id = aws_route_table.ob-private-route-table.id
}

