# ALBの作成
resource "aws_lb" "main" {
  name               = "${var.pj_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "${var.pj_name}-alb"
  }
}

# ALBリスナーの作成
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

# ターゲットグループの作成
resource "aws_lb_target_group" "app" {
  name        = "${var.pj_name}-tg"
  port        = 8501
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/_stcore/health"
    unhealthy_threshold = "2"
  }

  tags = {
    Name = "${var.pj_name}-tg"
  }
}



