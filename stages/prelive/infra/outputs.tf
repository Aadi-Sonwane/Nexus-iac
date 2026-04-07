# =================================================================
# Stage: Prelive | Layer: Infrastructure | File: outputs.tf
# Description: Bubbles up Infrastructure IDs for verification
# =================================================================

# --- 1. Access URLs ---
output "alb_dns_name" {
  description = "The Public DNS of the Load Balancer"
  value       = module.prelive_infra.alb_dns_name
}

output "nexus_public_url" {
  description = "The Final Secure DNS URL for Nexus"
  value       = "https://prelive.${var.domain_name}/nexus/" 
}

# --- 2. Resource Identifiers (Crucial for App Layer Handshake) ---
output "vpc_id" {
  value = module.prelive_infra.vpc_id
}

output "private_subnets" {
  value = module.prelive_infra.private_subnets
}

output "efs_id" {
  value = module.prelive_infra.efs_id
}

output "s3_bucket_id" {
  value = module.prelive_infra.s3_bucket_id
}

output "app_sg_id" {
  value = module.prelive_infra.app_sg_id
}

output "nexus_tg_arn" {
  value = module.prelive_infra.nexus_tg_arn
}

# Added this to support the NLB Instance-mode registration
output "nexus_ec2_tg_arn" {
  value = module.prelive_infra.nexus_ec2_tg_arn
}

# --- 3. DNS Action Item ---
output "route53_nameservers" {
  description = "IMPORTANT: Update these 4 nameservers at your domain registrar"
  value       = module.prelive_infra.nameservers
}