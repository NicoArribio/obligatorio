# --- Variables de Entrada (Inputs) ---
# Estos son los datos que necesitarás de otras partes del proyecto o de la configuración.

variable "key_name" {
  description = "Nombre del Key Pair de EC2 para el acceso SSH."
  type        = string
}


#Grupo de Seguridad para las Instancias del Auto Scaling
resource "aws_security_group" "instancia_sg" {
  name        = "instancia-autoscaling-sg"
  description = "Permite tráfico desde el Load Balancer y SSH"
  
  
  vpc_id      = aws_vpc.ob-vpc.id 

  # Regla de ENTRADA: Permite tráfico web (HTTP) SOLO desde el Load Balancer.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

   
    security_groups = [aws_security_group.ac1-lb-sg.id] 
  }

  # Regla de ENTRADA: Permite tu conexión SSH para mantenimiento.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de SALIDA: Permite a la instancia conectarse a internet.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Instancia-ASG-SG"
  }
}

#Búsqueda de la última AMI de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Plantilla Launch Template para el Auto Scaling
resource "aws_launch_template" "mi_launch_template" {
   name = "Launch-template-obligatorio"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  #Asocia el Security Group creado.
  vpc_security_group_ids = [aws_security_group.instancia_sg.id]

  # Script para instalar el servicio httpd al iniciar.
  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Instancia creada por Auto Scaling</h1>" > /var/www/html/index.html
              EOF
  )

  tags = {
    Name = "ASG-Launch-Template"
  }
}

# --- Salidas (Outputs) ---
# Estos son los datos que tu código le entrega al resto del proyecto.
output "launch_template_id" {
  description = "El ID de la plantilla de lanzamiento para usar en el Auto Scaling Group."
  value       = aws_launch_template.mi_launch_template.id
}

output "launch_template_latest_version" {
  description = "La última versión de la plantilla de lanzamiento."
  value       = aws_launch_template.mi_launch_template.latest_version
}