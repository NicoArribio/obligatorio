#Security Groups

resource "aws_security_group" "ob-sg" {
  name        = "ob-sg"
  description = "Permite ingreso http, https y ssh"
  vpc_id      = aws_vpc.ob-vpc.id

  # Reglas de entrada http,https y puerto 3306 de la base de datos
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    
    # Solo permite consultas desde nuestras subnets privadas
    cidr_blocks = [aws_subnet.ob-private-subnet.cidr_block, 
                   aws_subnet.ob-private-subnet2.cidr_block] 
  }

# Permite ssh para adininistracion

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Reglas de salida
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 significa todos los protocolos
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "ob-sg"
    Environment = "production"
  }
}