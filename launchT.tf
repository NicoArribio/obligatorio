# --- Variables de Entrada (Inputs) ---
# Estos son los datos que necesitarás de otras partes del proyecto o de la configuración.

variable "key_name" {
  description = "Nombre del Key Pair de EC2 para el acceso SSH."
  type        = string
}

variable "vpc_id" {
  description = "ID de la VPC donde se desplegarán los recursos."
  type        = string
}

variable "load_balancer_sg_id" {
  description = "El ID del Security Group del Load Balancer (te lo pasa tu compañero)."
  type        = string
}


# --- Recursos que tú creas ---

# 1. Grupo de Seguridad para las Instancias del Auto Scaling
# Este SG se asignará a cada instancia que se lance.
resource "aws_security_group" "instancia_sg" {
  name        = "instancia-autoscaling-sg"
  description = "Permite tráfico desde el Load Balancer y SSH"
  vpc_id      = var.vpc_id # Importante para que se cree en la VPC correcta.

  # Regla de ENTRADA: Permite tráfico web (HTTP) SOLO desde el Load Balancer.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.load_balancer_sg_id] # ¡Conexión clave!
  }

  # Regla de ENTRADA: Permite tu conexión SSH para mantenimiento.
  # ADVERTENCIA: Para producción, restringe "cidr_blocks" a tu IP.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Regla de SALIDA: Permite a la instancia conectarse a internet (para actualizaciones, etc.).
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

# 2. Búsqueda de la última AMI (Imagen) de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 3. Plantilla de Lanzamiento (Launch Template) para el Auto Scaling
resource "aws_launch_template" "mi_launch_template" {
  name_prefix = "asg-lt-"

  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  # Asociamos el Security Group que creamos justo arriba.
  vpc_security_group_ids = [aws_security_group.instancia_sg.id]

  # Script para instalar un servidor web al iniciar.
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