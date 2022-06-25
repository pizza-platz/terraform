data "aws_elb_service_account" "main" {}

resource "aws_lb" "this" {
  name               = var.name_prefix
  internal           = "false"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id]
  subnets            = module.vpc.public_subnets

  access_logs {
    bucket  = aws_s3_bucket.access_logs.bucket
    prefix  = var.name_prefix
    enabled = true
  }
}

resource "aws_security_group" "lb" {
  name   = "${var.name_prefix}-lb"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "lb_ingress_http" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "lb_ingress_https" {
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}

resource "aws_security_group_rule" "lb_instance_egress" {
  security_group_id        = aws_security_group.lb.id
  type                     = "egress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.instance.id
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.this.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name     = "${var.name_prefix}-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 10
    path                = "/api/v2/auth/m2"
    matcher             = ["401"]
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}
