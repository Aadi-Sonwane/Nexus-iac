# =================================================================
# Module: infra | File: outputs.tf
# Description: Definitions of all infrastructure resources exported 
#              for use by the Application (App) module.
# =================================================================

# --- 1. Networking Handshakes ---

output "vpc_id" {
  description = "The ID of the VPC where the application will reside"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC (needed for SG health check rules)"
  value       = aws_vpc.main.cidr_block
}

output "private_subnets" {
  description = "List of IDs of private subnets for the EC2 and EFS"
  value       = aws_subnet.private.*.id
}

output "public_subnets" {
  description = "List of IDs of public subnets for the ALB"
  value       = aws_subnet.public.*.id
}

# --- 2. Security Handshakes ---

output "app_sg_id" {
  description = "The ID of the Application Security Group"
  value       = aws_security_group.app_sg.id
}

output "alb_sg_id" {
  description = "The ID of the ALB Security Group"
  value       = aws_security_group.alb_sg.id
}

# --- 3. Storage Handshakes ---

output "efs_id" {
  description = "The ID of the EFS File System for persistent Nexus data"
  value       = aws_efs_file_system.nexus_data.id
}

output "s3_bucket_id" {
  description = "The name of the S3 bucket for Nexus Blob Storage"
  value       = aws_s3_bucket.nexus_blobs.id
}

# --- 4. Traffic & Load Balancing ---

output "nexus_tg_arn" {
  description = "The ARN of the ALB Target Group (IP-type) for Nexus UI"
  value       = aws_lb_target_group.nexus_nlb_target.arn
}

output "nexus_ec2_tg_arn" {
  description = "The ARN of the NLB Target Group (Instance-type) for TCP traffic"
  value       = aws_lb_target_group.nexus_ec2_target.arn
}

output "alb_dns_name" {
  description = "The public DNS name of the Application Load Balancer"
  value       = aws_lb.external_alb.dns_name
}

# --- 5. DNS & Domain ---

output "nameservers" {
  description = "The Name Servers for the Route 53 zone (Update your Registrar with these!)"
  value       = aws_route53_zone.main.name_servers
}

output "nexus_public_url" {
  description = "The official production URL for the Nexus Portal"
  value       = "https://prelive.${var.domain_name}/nexus/"
}