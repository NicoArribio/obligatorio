#Busqueda de la ultima AMI de Amazon Linux 2
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Plantilla  para el Auto Scaling
resource "aws_launch_template" "ob-lt" {
   name = "Launch-template-obligatorio"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  #Asocia el Security Group creado.
  vpc_security_group_ids = [aws_security_group.ob-sg.id]

  # Script al iniciar la instancia.

user_data = base64encode(<<-EOT
#!/bin/bash

# Actualiza paquetes  
  sudo yum update -y

# Insala GIT
  sudo yum install -y git

#Establece variables de entorno

  DB_ENDPOINT="${aws_db_instance.ob_database.address}" 
  DB_USERNAME="${var.db_username}"
  DB_PASSWORD="${var.db_password}"
  DB_NAME="${var.db_name}"
  SQL_FILE="db-settings.sql"

 #Clonamos repositorio
  git clone https://github.com/NicoArribio/ModifiedApp
  cd ModifiedApp

#Instalamos mysql

  sudo yum install -y mysql

# Instentamos conctar con base RDS hasta que la conexión sea exitosa

  until mysql -h "$DB_ENDPOINT" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "SELECT 1;" > /dev/null 2>&1; do
      sleep 5
  done

# Importamos estructura de base de datos

  mysql -h "$DB_ENDPOINT" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_NAME" < "$SQL_FILE"

# Instalamos Docker

  sudo yum install -y docker
  sudo systemctl start docker
  sudo systemctl enable docker

# Traemos imagen

  sudo docker pull 181345/obligatorio:latest

# Creamos contenedor

  sudo docker run -d -p 80:80 \
      -e DB_HOST="$DB_ENDPOINT" \
      -e DB_NAME="$DB_NAME" \
      -e DB_USER="$DB_USERNAME" \
      -e DB_PASSWORD="$DB_PASSWORD" \
      181345/obligatorio:latest

EOT
)

  tags = {
    Name = "ASG-Launch-Template"
  }
}

