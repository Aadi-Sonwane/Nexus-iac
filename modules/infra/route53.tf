# =================================================================
# Module: infra | File: route53.tf
# Description: DNS Management and Alias Records for RankHex
# =================================================================

# --- 1. Create the Route53 Hosted Zone ---
# This is the "Phonebook" for your domain
resource "aws_route53_zone" "main" {
  name          = var.domain_name
  force_destroy = false # Safety: Don't delete the zone if it contains records

  tags = { 
    Name = "${var.project_name}-hosted-zone" 
    Environment = var.env
  }
}

# --- 2. Public DNS Record (ALB) ---
# Points prelive.rankhex.in to the Application Load Balancer
resource "aws_route53_record" "route53_record_main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "prelive.${var.domain_name}"
  type    = "A"

  # Alias is better than CNAME: It's free and faster in AWS
  alias {
    name                   = aws_lb.external_alb.dns_name
    zone_id                = aws_lb.external_alb.zone_id
    evaluate_target_health = true
  }
}

# --- 3. Internal DNS Record (NLB) ---
# Points internal-dns.prelive.rankhex.in to the Network Load Balancer
# Used for high-speed TCP traffic or internal DevOps tooling
resource "aws_route53_record" "route53_record_internal" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "internal-dns.prelive.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.internal_nlb.dns_name
    zone_id                = aws_lb.internal_nlb.zone_id
    evaluate_target_health = true
  }
}