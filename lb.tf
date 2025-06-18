# Creo el target group vacio

resource "aws_lb_target_group" "ob-tg" {
  name        = "ob-tg"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ob-vpc.id

  # health_check 
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-299"
  }
} 

# Creo el ALB

resource "aws_lb" "ob-lb" {
  name               = "ob-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ob-sg.id]
  subnets            = [aws_subnet.ob-public-subnet.id,aws_subnet.ob-public-subnet2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "ob-listener" {
  load_balancer_arn = aws_lb.ob-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ob-tg.arn
  }
}


resource "aws_lb_listener_rule" "ob-listener-rule" {
  listener_arn = aws_lb_listener.ob-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ob-tg.arn

  }

  condition {
    path_pattern {
      values = ["/index.html"]
    }
  }
}

# Creo un Auto Scaling Group

resource "aws_autoscaling_group" "ob-asg" {

  #Le decimos al ASG el tipo de instancia EC2 que debe lanzar.
  launch_template {
    id      = aws_launch_template.ob-lt.id
    version = aws_launch_template.ob-lt.latest_version
  }
  #en que subnet deben ir
  vpc_zone_identifier = [
    aws_subnet.ob-private-subnet.id,
    aws_subnet.ob-private-subnet2.id
  ]
  #Definimos la capacidad deseada tanto minimo cmo maximo de intancias.
  min_size                  = 1
  max_size                  = 2
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300

  target_group_arns = [aws_lb_target_group.ob-tg.arn]

  tag {
    key                 = "Environment"
    value               = "production"
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "AutoScaling-Instance"
    propagate_at_launch = true
  }
}

# --- Politicas de Auto Scaling ---

# Politica de escalado ascendente (Scale Up)
resource "aws_autoscaling_policy" "ob_scale_up_policy" {
  name                   = "ob-asg-scale-up"
  autoscaling_group_name = aws_autoscaling_group.ob-asg.name
  policy_type            = "SimpleScaling"

  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity" 
  metric_aggregation_type = "Average"

  cooldown = 300
}

# Politica de escalado descendente (Scale Down)
resource "aws_autoscaling_policy" "ob_scale_down_policy" {
  name                   = "ob-asg-scale-down"
  autoscaling_group_name = aws_autoscaling_group.ob-asg.name
  policy_type            = "SimpleScaling"

  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  metric_aggregation_type = "Average"

  cooldown = 300
}

# le damos una salida al dns del load para que lo muestre al terminar terraform

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.ob-lb.dns_name
}