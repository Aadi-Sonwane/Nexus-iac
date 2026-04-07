# =================================================================
# Module: app
# File: outputs.tf
# Description: Exports Application-specific IDs and Metadata
# =================================================================

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.nexus_asg.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.nexus_asg.arn
}

output "iam_role_name" {
  description = "The name of the IAM role attached to Nexus"
  value       = aws_iam_role.nexus_role.name
}

output "iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.nexus_role.arn
}

output "launch_template_id" {
  description = "The ID of the Launch Template used for Nexus"
  value       = aws_launch_template.nexus.id
}

output "nexus_cloudinit_rendered" {
  description = "The rendered cloud-init configuration (useful for debugging)"
  value       = data.cloudinit_config.nexus_setup.rendered
  sensitive   = true
}