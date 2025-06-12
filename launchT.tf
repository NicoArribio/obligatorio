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
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              
              # Apache
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              sudo echo "Esta es la instancia $HOSTNAME" > /var/www/html/index.html
              

              # MySQL

              sudo yum install mysql -y
              sudo systemctl start mysql
              sudo systemctl enable mysql
              
              EOF

              
  )

  tags = {
    Name = "ASG-Launch-Template"
  }
}