# ### variables.tf ###

variable "vpc_cidr" {
  description = "Rango CIDR para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "Rango CIDR para la Subnet Pública 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "Rango CIDR para la Subnet Pública 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "private_subnet_1_cidr" {
  description = "Rango CIDR para la Subnet Privada 1"
  type        = string
  default     = "10.0.101.0/24"
}

variable "private_subnet_2_cidr" {
  description = "Rango CIDR para la Subnet Privada 2"
  type        = string
  default     = "10.0.102.0/24"
}

variable "aws_az_1" {
  description = "Availability Zone 1 (ej: us-east-1a)"
  type        = string
  default     = "us-east-1a"
}

variable "aws_az_2" {
  description = "Availability Zone 2 (ej: us-east-1b)"
  type        = string
  default     = "us-east-1b"
}

variable "key_name" {
  description = "Nombre del Key Pair de EC2 para acceso SSH. Este valor DEBE ser proporcionado."
  type        = string
}

# --- SALIDA FINAL ---
# Este es el dato más importante para probar que todo funciona.
output "load_balancer_dns" {
  description = "El nombre DNS público del Load Balancer para acceder a la aplicación."
  value       = aws_lb.ob_lb.dns_name
}