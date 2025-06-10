# --- 1. GRUPO DE SUBNETS PARA RDS ---
resource "aws_db_subnet_group" "ob_db_subnet_group" {
  name       = "ob-db-subnet-group"
  ### CONEXIÓN: Usa las subnets privadas que definirás en 'network.tf'
  subnet_ids = [aws_subnet.ob_private_subnet_1.id, aws_subnet.ob_private_subnet_2.id]

  tags = {
    Name = "OB DB Subnet Group"
  }
}

# --- 2. SECURITY GROUP PARA LA BASE DE DATOS ---
# Creamos un firewall específico para la base de datos.
resource "aws_security_group" "db_sg" {
  name        = "database-sg"
  description = "Permite conexiones a la BD solo desde las instancias de la aplicación"
  ### CONEXIÓN: Se asocia a la VPC principal definida en 'network.tf'
  vpc_id      = aws_vpc.ob_vpc.id

  # Regla de ENTRADA: Permite tráfico en el puerto de MySQL (3306)
  # SOLAMENTE desde los recursos que tengan el Security Group de las instancias.
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    ### CONEXIÓN CLAVE: Apunta al 'instancia_sg' que definirás en 'instancia.tf'
    security_groups = [aws_security_group.instancia_sg.id]
  }

  # Regla de SALIDA: Permite a la BD conectarse hacia afuera si necesita (ej. para parches).
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Database-SG"
  }
}

# --- 3. INSTANCIA DE RDS ---
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
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  # --- PARÁMETROS IMPORTANTES ---
  multi_az               = false # <-- CAMBIO CLAVE: Se desactiva Multi-AZ por limitaciones de la cuenta.
  backup_retention_period = 7      # <-- SE MANTIENE: Esta es tu solución de respaldos.
  publicly_accessible  = false # MUY IMPORTANTE: La BD no será accesible desde internet.
  skip_final_snapshot  = true  # Facilita la destrucción en entornos de prueba.

  tags = {
    Name = "OB-Database"
  }
}