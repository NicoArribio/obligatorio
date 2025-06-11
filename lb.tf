# ### lb.tf ###

resource "aws_security_group" "ob_lb_sg" {
  name        = "ob-load-balancer-sg"
  description = "Permite trafico HTTP desde internet hacia el LB"
  vpc_id      = aws_vpc.ob_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "ob-lb-sg" }
}

resource "aws_lb_target_group" "ob_tg" {
  name        = "ob-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ob_vpc.id
  target_type = "instance"
  health_check {
    path                = "/"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb" "ob_lb" {
  name               = "ob-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ob_lb_sg.id]
  subnets            = [aws_subnet.ob_public_subnet_1.id, aws_subnet.ob_public_subnet_2.id]
  tags               = { Name = "ob-lb" }
}

resource "aws_lb_listener" "ob_listener" {
  load_balancer_arn = aws_lb.ob_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ob_tg.arn
  }
}