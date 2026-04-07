# =================================================================
# Module: infra | File: variables.tf
# Description: Input definitions for the Infrastructure Layer
# =================================================================

variable "project_name" {
  description = "The name of the project (e.g., google.com)"
  type        = string
}

variable "env" {
  description = "The deployment environment (e.g., prelive, live)"
  type        = string
}

variable "region" {
  description = "The AWS region for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "account_id" {
  description = "The AWS Account ID (used for unique S3 naming)"
  type        = string
}

# --- Networking Variables ---

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "azs" {
  description = "List of Availability Zones"
  type        = list(string)
}

# --- DNS Variables ---

variable "domain_name" {
  description = "The root domain (e.g., trainwithats.online)"
  type        = string
}
