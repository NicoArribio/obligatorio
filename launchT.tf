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
resource "aws_launch_template" "ob-lt" {
   name = "Launch-template-obligatorio"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  #Asocia el Security Group creado.
  vpc_security_group_ids = [aws_security_group.ob-sg.id]

  # Script para instalar el servicio httpd al iniciar.

user_data = base64encode(<<-EOT
  #!/bin/bash

    # Instalamos Git si no está ya instalado
    if ! command -v git &> /dev/null; then
        sudo yum install -y git
    fi

   # Traemos el repositorio
    git clone https://github.com/NicoArribio/ModifiedApp
    cd ModifiedApp

    # Instalamos MariaDB
    sudo yum install -y mysql

    # Obtenemos los valores de Terraform para el endpoint y credenciales
    DB_ENDPOINT="${aws_db_instance.ob_database.address}"
    DB_USERNAME="${var.db_username}"
    DB_PASSWORD="${var.db_password}" # ¡ADVERTENCIA DE SEGURIDAD! Ver nota abajo.
    DB_NAME="${var.db_name}"
    SQL_FILE="db-settings.sql"

    echo "Esperando a que la base de datos esté disponible..."
  # Bucle para esperar a que la base de datos responda antes de intentar importar
  # Esto es crucial ya que RDS puede tardar un poco en estar completamente operativo
  until mysql -h $DB_ENDPOINT -u $DB_USERNAME -p$DB_PASSWORD -e "SELECT 1;" > /dev/null 2>&1; do
      echo "Base de datos no disponible todavía, reintentando en 5 segundos..."
      sleep 5
  done
  echo "Base de datos disponible. Importando esquema..."

  # Importar el archivo SQL
  # Usamos "$DB_PASSWORD" entre comillas dobles por si la contraseña tiene caracteres especiales
  mysql -h $DB_ENDPOINT -u $DB_USERNAME -p"$DB_PASSWORD" $DB_NAME < "$SQL_FILE"

  echo "Esquema de la base de datos importado."

    # Instalamos Docker si no está ya instalado
    if ! command -v docker &> /dev/null; then
        sudo yum install -y docker
        sudo systemctl start docker
        sudo systemctl enable docker
    fi

    # Construimos la imagen de Docker
    sudo docker build -t ecommerce-app .

    # Ejecutamos el contenedor en segundo plano
    sudo docker run -d -p 80:80 ecommerce-app

EOT
)

  tags = {
    Name = "ASG-Launch-Template"
  }
}

