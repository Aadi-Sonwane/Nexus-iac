# =================================================================
# Stage: Prelive
# Layer: Infrastructure
# File: variables.tf
# Description: Defines inputs for the Prelive environment
# =================================================================

# --- Global Identifiers ---

variable "project_name" {
  description = "Name of the project (e.g., google.com)"
  type        = string
  default     = "trainwithats"
}

variable "region" {
  description = "AWS Region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "account_id" {
  description = "Your AWS Account ID (to ensure unique S3 bucket names)"
  type        = string
}

# --- Networking Configuration ---

variable "vpc_cidr" {
  description = "CIDR block for the Prelive VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDRs (for ALB/NAT)"
  type        = list(string)
  default     = ["10.10.1.0/24", "10.10.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDRs (for Nexus App)"
  type        = list(string)
  default     = ["10.10.4.0/24", "10.10.5.0/24"]
}

variable "azs" {
  description = "Availability Zones to be used"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

# --- DNS Configuration ---

variable "domain_name" {
  description = "The registered domain name in Route53"
  type        = string
  default     = "trainwithats.online"
}