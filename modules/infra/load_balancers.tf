# =================================================================
# Module: infra | File: load_balancers.tf
# Description: Dual-LB Architecture for Public and Internal access
# =================================================================

# --- 1. External Application Load Balancer (Public Facing) ---
resource "aws_lb" "external_alb" {
  name               = "${var.project_name}-${var.env}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public.*.id

  tags = { Name = "${var.project_name}-${var.env}-alb" }
}

# --- 2. Internal Network Load Balancer (Internal TCP Speed) ---
resource "aws_lb" "internal_nlb" {
  name               = "${var.project_name}-${var.env}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = aws_subnet.private.*.id

  tags = { Name = "${var.project_name}-${var.env}-nlb" }
}

# --- 3. Target Groups ---

# ALB Target Group: Uses IP mode for bridge routing
resource "aws_lb_target_group" "nexus_nlb_target" {
  name        = "${var.env}-nexus-nlb-tg"
  port        = 8081
  protocol    = "HTTP" 
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol            = "HTTP"
    path                = "/nexus/" # CRITICAL: Trailing slash is required for Nexus 3
    port                = "8081"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200,302" # High-compatibility for redirect-heavy logins
  }
}

# NLB Target Group: Uses Instance mode for direct routing
resource "aws_lb_target_group" "nexus_ec2_target" {
  name        = "${var.env}-nexus-ec2-tg"
  port        = 8081
  protocol    = "TCP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    protocol = "TCP"
    port     = "8081"
  }
}

# --- 4. ALB Listeners & Routing ---

# Redirect HTTP to HTTPS
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.external_alb.arn
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

# Secure HTTPS Listener using ACM Cert
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate_validation.public_ssl_cert_valid.certificate_arn

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "RankHex Secure Entry Point. Access denied."
      status_code  = "403"
    }
  }
}

# Rule: Forward /nexus path to the application
resource "aws_lb_listener_rule" "nexus_path" {
  listener_arn = aws_lb_listener.https.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus_nlb_target.arn
  }
  condition {
    path_pattern { values = ["/nexus*"] }
  }
}

# NLB Internal TCP Listener
resource "aws_lb_listener" "nlb_nexus_listener" {
  load_balancer_arn = aws_lb.internal_nlb.arn
  port              = "8081"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nexus_ec2_target.arn
  }
}