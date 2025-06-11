# ### instancia.tf ###

resource "aws_security_group" "instancia_sg" {
  name        = "instancia-autoscaling-sg"
  description = "Permite trafico desde el Load Balancer y SSH"
  vpc_id      = aws_vpc.ob_vpc.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.ob_lb_sg.id]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "Instancia-ASG-SG" }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_template" "ob_launch_template" {
  name          = "Launch-template-obligatorio"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.instancia_sg.id]
  user_data = base64encode(file("${path.module}/install_httpd.sh"))
  tags = { Name = "ob-launch-template" }
}

resource "aws_autoscaling_group" "ob_asg" {
  name_prefix         = "ob-asg-"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  
  vpc_zone_identifier = [aws_subnet.ob_private_subnet_1.id, aws_subnet.ob_private_subnet_2.id]

  launch_template {
    id      = aws_launch_template.ob_launch_template.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.ob_tg.arn]

  ### SECCIÓN CORREGIDA ###
  tag {
    key                 = "Name"
    value               = "ob-asg-instance"
    propagate_at_launch = true # Esto asegura que las instancias EC2 también reciban esta etiqueta
  }
}