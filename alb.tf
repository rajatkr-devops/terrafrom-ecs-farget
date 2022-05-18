resource "aws_security_group" "lb_sg" {
  name   = "${var.name}-sg-alb-${var.environment}"
  vpc_id = var.vpc_id
 
  ingress {
   protocol         = "tcp"
   from_port        = 80
   to_port          = 80
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  ingress {
   protocol         = "tcp"
   from_port        = 443
   to_port          = 443
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
 
  egress {
   protocol         = "-1"
   from_port        = 0
   to_port          = 0
   cidr_blocks      = ["0.0.0.0/0"]
   ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_lb" "lb" {
  name               = "${var.name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = var.subnets
 
  enable_deletion_protection = false
  # dynamic "subnet_mapping" {
  #   for_each = var.subnet_mapping

  #   content {
  #     subnet_id     = subnet_mapping.value.subnet_id
  #     allocation_id = lookup(subnet_mapping.value, "allocation_id", null)
  #   }
  # }
}
 
resource "aws_alb_target_group" "target" {
  name        = "${var.name}-tg-${var.environment}"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
 
  health_check {
   healthy_threshold   = "3"
   interval            = "30"
   protocol            = "HTTP"
   matcher             = "200"
   timeout             = "3"
   path                = var.health_check_path
   unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "http" {
  depends_on   = ["aws_alb_target_group.target"]
  load_balancer_arn = aws_lb.lb.id
  port              = 80
  protocol          = "HTTP"
 
  # default_action {
  #  type = "redirect"
 
  #  redirect {
  #    port        = 443
  #    protocol    = "HTTPS"
  #    status_code = "HTTP_301"
  #  }
  # }
     default_action {
    target_group_arn = aws_alb_target_group.target.id
    type             = "forward"
  }
}
 
# resource "aws_alb_listener" "https" {
#   load_balancer_arn = aws_lb.lb.id
#   port              = 443
#   protocol          = "HTTPS"
 
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = var.alb_tls_cert_arn
 
#   default_action {
#     target_group_arn = aws_alb_target_group.target.id
#     type             = "forward"
#   }
# }
