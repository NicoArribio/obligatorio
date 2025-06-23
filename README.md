🛒 Online E-commerce


Este es un proyecto de aplicación web de comercio electrónico desarrollado en PHP, diseñado para ser desplegado de manera elástica y observable en Amazon Web Services (AWS) utilizando Terraform como herramienta de Infraestructura como Código (IaC).

El proyecto utiliza un sistema de enrutamiento personalizado en PHP, donde todas las rutas son gestionadas desde index.php, en lugar de depender del servidor web para mapear rutas a archivos físicos. La aplicación está contenerizada con Docker para facilitar su despliegque y portabilidad.


🚀 Objetivo


El objetivo principal de este proyecto es explorar la migración y modernización del componente frontend de una solución de e-commerce existente (actualmente en infraestructura on-premise) hacia la Cloud Pública de Amazon Web Services (AWS).

Se busca demostrar la capacidad de desplegar y gestionar una aplicación web con alta disponibilidad y escalabilidad en un entorno de nube, como respuesta a un incremento significativo del tráfico y la degradación del servicio.

Específicamente, el proyecto se enfoca en:

Construir un frontend de tienda online funcional en PHP que permita a los usuarios explorar productos, ver detalles, autenticarse y realizar compras.

Demostrar un despliegue elástico y robusto en AWS utilizando Infraestructura como Código (Terraform) y contenerización (Docker).

Aplicar principios de alta disponibilidad, seguridad y monitoreo automatizado para asegurar la performance y la experiencia del usuario.


☁️ Arquitectura del Despliegue en AWS


La infraestructura se diseña para ser elástica y resiliente, distribuida en múltiples Zonas de Disponibilidad (AZs) dentro de una Virtual Private Cloud (VPC) dedicada.

Componentes Clave de la Arquitectura:

Amazon VPC: Una red virtual aislada, dividida en subredes públicas y privadas en dos Zonas de Disponibilidad (us-east-1a y us-east-1b).

Subredes Públicas: Albergan el Application Load Balancer (ALB) y un NAT Gateway.

Subredes Privadas de Aplicación: Contienen las instancias EC2 de la aplicación, gestionadas por un Auto Scaling Group.

Application Load Balancer (ALB): Distribuye el tráfico entrante a través de las instancias de aplicación.

Auto Scaling Group (ASG):: Mantiene la disponibilidad de la aplicación y escala las instancias EC2 automáticamente según la demanda.

Amazon RDS (MySQL): Instancia de base de datos MySQL gestionada, ubicada de forma segura en las subredes privadas.

Security Groups: Actúan como firewalls a nivel de instancia, controlando el tráfico de entrada y salida permitido.

NAT Gateway: Permite que las instancias en subredes privadas inicien conexiones salientes a Internet (ej. para actualizaciones o clonar el código de GitHub) sin ser accesibles desde el exterior.

CloudWatch Alarms: Monitorean el rendimiento de las instancias y activan políticas de autoescalado.

GitHub: Repositorio de código fuente, clonado por las instancias al iniciarse.


💻 Componentes de la Aplicación


Aplicación PHP: El core del comercio electrónico, con lógica de negocio para productos, usuarios, carritos y órdenes.

Enrutamiento Personalizado: Gestionado por las clases Route en router.php e index.php, permitiendo URLs amigables sin depender de configuraciones de servidor web complejas.

Conexión a Base de Datos: bk_db.php establece la conexión PDO a la base de datos MySQL, obteniendo las credenciales de variables de entorno para mayor seguridad.

Protección CSRF: Implementar una clase CSRF (csrf.php) para generar y validar tokens de seguridad, protegiendo contra ataques de falsificación de solicitudes entre sitios.

Dockerfile: Define el entorno de ejecución (PHP 8.2 con Apache) y empaqueta la aplicación en una imagen Docker, asegurando un entorno consistente en todas las instancias.

🔧 Componentes de la Infraestructura AWS (Terraform)

Todos los recursos de infraestructura se definen y gestionan mediante Terraform.

VPC (network.tf): Crea la VPC con sus subredes públicas y privadas, Internet Gateway y NAT Gateway.

Security Group (ob-sg.tf):: Define las reglas de firewall que controlan el tráfico hacia y desde el ALB, las instancias EC2 y la base de datos RDS. Incluye reglas para HTTP, HTTPS, SSH y MySQL (restringido a subredes privadas).

RDS (BD.tf):: Provisión de una instancia de base de datos MySQL. Configuraciones clave como publicly_accessible = false (solo accesible desde la VPC) y backup_retention_period = 7 (7 días de respaldos automáticos).

Launch Template (launchT.tf):: Plantilla que especifica cómo se deben lanzar las instancias EC2 (AMI, tipo t2.micro, clave SSH, Security Group, y un script user_data que configura la instancia al inicio).

Load Balancer y Auto Scaling (lb.tf): Configura el ALB, sus listeners y Target Group. Define el Auto Scaling Group, sus min_size, max_size, desired_capacity, y las políticas de escalado ascendente/descendente (SimpleScaling).

Monitoreo (monitoring.tf):: Define las alarmas de CloudWatch que monitorean la CPUUtilization del ASG y activan las políticas de autoescalado.

Variables (variables.tf, terraform.tfvars): Definen los parámetros configurables para el despliegue (región, CIDRs, credenciales DB, etc.).

✨ Características Clave y Mejoras Implementadas

Despliegue Automatizado (IaC): Toda la infraestructura se define en código Terraform, permitiendo un despliegue repetible y consistente.

Alta Disponibilidad: Distribución de recursos en dos Zonas de Disponibilidad.

Escalabilidad Automática: El ASG lanza y termina instancias según la carga de CPU, garantizando el rendimiento y optimizando costos.

Monitoreo Activo: Alarmas de CloudWatch (high_cpu_alarm, low_cpu_alarm) monitorean proactivamente el uso de CPU y activan las políticas de autoescalado.

Seguridad de Red: Uso estratégico de Security Groups y subredes privadas para aislar la base de datos y la aplicación.

Base de Datos Gestionada: RDS simplifica la administración de la base de datos, incluyendo respaldos automáticos.

Contenerización: Uso de Docker para un entorno de aplicación portátil y aislado.

🚀 Guía de Despliegue Rápido

Sigue estos pasos para desplegar la aplicación en tu cuenta de AWS utilizando Terraform.

Prerrequisitos:
Acceso a una Cuenta de AWS: Necesitarás una cuenta AWS activa con permisos suficientes para crear y gestionar recursos en EC2, VPC, RDS, S3, IAM y CloudWatch.

AWS CLI: El AWS Command Line Interface debe estar instalado y configurado con tus credenciales.

Terraform: Terraform (versión 1.0+ recomendada) debe estar instalado.

Git: Git debe estar instalado.

Clave SSH de AWS: Debes tener una clave SSH (.pem o .ppk) existente en tu cuenta de AWS para la región us-east-1 (el key_name por defecto en terraform.tfvars es vockey).

1. Clonar el Repositorio:
   
git clone https://github.com/NicoArribio/obligatorio


2. Inicializar Terraform:
terraform init

3. Planificar el Despliegue:
terraform plan

4. Aplicar el Despliegue:
terraform apply

5. Acceder a la Aplicación:
Una vez que terraform apply finalice con éxito, Terraform mostrará el DNS del Application Load Balancer (ALB) en la salida.

Copia el valor del alb_dns_name que se muestra.

Pega este DNS en tu navegador web. La aplicación debería estar accesible.

Ejemplo de URL: http://ob-lb-xxxxxxxxxxxx.us-east-1.elb.amazonaws.com

Para acceder al panel de administración, usa: http://<ALB_DNS_NAME>/admin/login con las credenciales por defecto

🚧 Desafíos y Aprendizajes
Durante el desarrollo y despliegue del proyecto, surgieron varios desafíos que proporcionaron valiosas lecciones:

Gestión del Estado de Terraform: La importancia de mantener el estado de Terraform (.tfstate) sincronizado con la infraestructura real en AWS. Uso de terraform import y terraform state rm para resolver inconsistencias.

Resolución de Dependencias en la Nube: Dificultades para eliminar recursos debido a dependencias ocultas o huérfanas (ej., Interfaces de Red ENI que bloquean la eliminación de subredes y VPCs), requiriendo un orden específico de eliminación y, a veces, intervención manual.

Restricciones de Cuentas Educativas / IAM: Limitaciones de permisos (iam:CreateRole) para crear nuevos roles IAM, lo que impidió la implementación de la centralización de logs con el Agente de CloudWatch Logs, destacando la importancia de la gestión de permisos en entornos compartidos.

Depuración de Código Terraform: Aprender a interpretar mensajes de error detallados del proveedor AWS y corregir la sintaxis específica (scaling_adjustment en políticas SimpleScaling, sintaxis de S3 acl y ownership_controls).

🚀 Mejoras Futuras
Para continuar evolucionando este proyecto, se proponen las siguientes mejoras:

Centralización de Logs:

Implementar el Agente de CloudWatch para recopilar y centralizar logs de Apache, Docker y PHP en CloudWatch Logs (una vez que los permisos IAM lo permitan).

Configurar exportación de logs a S3 para archivado a largo plazo.

Seguridad HTTPS:

Configurar un Listener HTTPS en el ALB con un certificado SSL/TLS de AWS Certificate Manager (ACM).

Implementar redirección automática de HTTP a HTTPS.

Gestión Segura de Secretos:

Utilizar AWS Secrets Manager o AWS Parameter Store para almacenar y recuperar de forma segura las credenciales de la base de datos, eliminándolas del terraform.tfvars.

Alta Disponibilidad de Base de Datos:

Configurar la instancia RDS en modo Multi-AZ para proporcionar una réplica en espera en otra Zona de Disponibilidad, mejorando la tolerancia a fallos.

CI/CD (Integración Continua/Despliegue Continuo):

Configurar un pipeline de CI/CD (ej., con AWS CodePipeline/CodeBuild o GitHub Actions) para automatizar las actualizaciones de la aplicación.

Instancia Bastión para Mantenimiento:

Implementar una instancia Bastión en una subred pública para acceso seguro y controlado por SSH a las instancias de aplicación en las subredes privadas. Esto centraliza el acceso de administración.

🔑 Credenciales de Administración (Solo para Entornos de Prueba)
Para acceder al panel de administración de la aplicación:

URI: /admin/login

Usuario: admin

Contraseña: 123456
