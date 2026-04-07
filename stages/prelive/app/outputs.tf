# =================================================================
# Stage: Prelive
# Layer: Application
# File: outputs.tf
# Description: Final outputs for the Nexus Application deployment
# =================================================================

# --- 1. Compute Identifiers ---

output "nexus_asg_name" {
  description = "The name of the Auto Scaling Group for Nexus"
  value       = module.prelive_nexus.asg_name
}

output "nexus_iam_role_arn" {
  description = "The ARN of the IAM Role used by the Nexus server"
  value       = module.prelive_nexus.iam_role_arn
}

# --- 2. Deployment Status ---

output "nexus_instance_profile" {
  description = "The name of the Instance Profile attached to the EC2"
  value       = "${var.project_name}-prelive-nexus-profile"
}

# --- 3. Access Confirmation ---

output "deployment_summary" {
  description = "Quick summary of the deployment"
  value       = <<EOF
---------------------------------------------------------
Nexus Deployment for RankHex (Prelive) is Complete!
---------------------------------------------------------
Region:        ${var.region}
Instance Type: ${var.instance_type}
ASG Name:      ${module.prelive_nexus.asg_name}
Target Group:  ${data.terraform_remote_state.infra.outputs.nexus_tg_arn}
---------------------------------------------------------
Access your instance via the ALB DNS provided in the 
Infrastructure stage outputs at /nexus.
---------------------------------------------------------
EOF
}