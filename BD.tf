# ---  Grupo de Subnet para RDS ---
resource "aws_db_subnet_group" "ob_db_subnet_group" {
  name       = "ob-db-subnet-group"
  # Usa las subnets privadas que estan definidas en network.tf
  subnet_ids = [aws_subnet.ob-private-subnet.id, aws_subnet.ob-private-subnet2.id]

  tags = {
    Name = "OB-DB"
  }
}

# Este es el recurso que crea la base de datos.
resource "aws_db_instance" "ob_database" {
  identifier           = "ob-database-mysql"
  allocated_storage    = 20                
  instance_class       = "db.t3.micro"     
  engine               = "mysql"
  engine_version       = "8.0"
  
  # Credenciales tomadas de la variables.tf
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password

  # CONEXIONES de Red y Seguridad
  db_subnet_group_name   = aws_db_subnet_group.ob_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.ob-sg.id]

  # --- Configuraciones importantes ---
  multi_az               = false # Se desactiva Multi-AZ por limitaciones de la cuenta de estudiante.
  backup_retention_period = 7      # Se guardan hasta 7 respaldos 
  publicly_accessible  = false # La BD no es accesible desde internet
  skip_final_snapshot  = true  

  tags = {
    Name = "OB-Database"
  }
}

#le damos una salida cuando termina de ejecutar terraform
output "rds_endpoint" {
  value = aws_db_instance.ob_database.endpoint
}