# Creo el TARGET GROUP vacío

resource "aws_lb_target_group" "ob-tg" {
  name        = "ob-tg"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc-ob.id
}

resource "aws_lb" "ac1-lb" {
  name               = "ac1-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ac1-lb-sg.id]
  subnets            = [aws_subnet.ac1-private-subnet.id, aws_subnet.ac1-private-subnet-2.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

resource "aws_lb_listener" "ac1-listener" {
  load_balancer_arn = aws_lb.ac1-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ac1-tg.arn
  }
}


resource "aws_lb_listener_rule" "ac1-listener-rule" {
  listener_arn = aws_lb_listener.ac1-listner.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ac1-tg.arn

  }

  condition {
    path_pattern {
      values = ["/var/www/html/index.html"]
    }
  }
}
