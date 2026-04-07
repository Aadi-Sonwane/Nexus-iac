# =================================================================
# Stage: Prelive
# Layer: Application
# File: variables.tf
# Description: Inputs for the Nexus Application deployment
# =================================================================

# --- Metadata ---

variable "project_name" {
  description = "The name of the project (e.g., google.com)"
  type        = string
  default     = "trainwithats"
}

variable "region" {
  description = "The AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

# --- Compute Configuration ---

variable "instance_type" {
  description = "The EC2 instance type for Nexus (Prelive standard: t3.medium)"
  type        = string
  default     = "t3.medium"
}

# --- AMI Override (Optional) ---
# Usually sourced from data.tf, but kept here if a specific AMI is needed
variable "ami_id" {
  description = "Optional AMI ID override"
  type        = string
  default     = null
}

# --- Tagging ---

variable "owner" {
  description = "Owner of the resources"
  type        = string
  default     = "Aditya Sonwane"
}