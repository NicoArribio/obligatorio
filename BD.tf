# --- 1. GRUPO DE SUBNETS PARA RDS ---
resource "aws_db_subnet_group" "ob_db_subnet_group" {
  name       = "ob-db-subnet-group"
  ### CONEXIÓN: Usa las subnets privadas que definirás en 'network.tf'
  subnet_ids = [aws_subnet.ob-private-subnet.id, aws_subnet.ob-private-subnet2.id]

  tags = {
    Name = "OB-DB"
  }
}

# Este es el recurso que crea la base de datos gestionada.
resource "aws_db_instance" "ob_database" {
  identifier           = "ob-database-mysql"
  allocated_storage    = 20                
  instance_class       = "db.t3.micro"     
  engine               = "mysql"
  engine_version       = "8.0"
  
  # Credenciales tomadas de las variables (definirlas en variables.tf)
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password

  # CONEXIONES de Red y Seguridad
  db_subnet_group_name   = aws_db_subnet_group.ob_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.ob-sg.id]

  # --- PARÁMETROS IMPORTANTES ---
  multi_az               = false # Se desactiva Multi-AZ por limitaciones de la cuenta.
  backup_retention_period = 7      # Solución de respaldos. Guarda 7
  publicly_accessible  = false # La BD no será accesible desde internet.
  skip_final_snapshot  = true  # Facilita la destrucción en entornos de prueba como el nuestro.

  tags = {
    Name = "OB-Database"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.ob_database.endpoint
}