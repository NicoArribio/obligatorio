# Creo el TARGET GROUP vacío

resource "aws_lb_target_group" "ob-tg" {
  name        = "ob-tg"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ob-vpc.id
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

# Creo un Auti Scalling Group

resource "aws_autoscaling_group" "ob-asg" {
  launch_template {
    id      = aws_launch_template.ob-lt.id
    version = aws_launch_template.ob-lt.latest_version
  }

  vpc_zone_identifier = [
    aws_subnet.ob-private-subnet.id,
    aws_subnet.ob-private-subnet2.id
  ]

  min_size                  = 1
  max_size                  = 3
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