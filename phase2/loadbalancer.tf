# Load Balancer
resource "aws_lb" "main_lb" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [for s in aws_subnet.subs : s.id]
  security_groups    = [aws_security_group.ec2_sg.id]

  tags = {
    Name = "main-lb"
  }
}

# Target Group
resource "aws_lb_target_group" "tg" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Enregistrement des instances EC2 dans le Target Group
resource "aws_lb_target_group_attachment" "attach" {
  for_each          = aws_instance.ec2
  target_group_arn  = aws_lb_target_group.tg.arn
  target_id         = each.value.id
  port              = 80
}

# Listener HTTP
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
