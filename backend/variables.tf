# =================================================================
# Folder: backend
# File: variables.tf
# Description: Definitions for the Remote State Bootstrap
# =================================================================

variable "region" {
  description = "AWS Region where the state resources will reside"
  type        = string
  default     = "us-east-1"
}

variable "account_id" {
  description = "Your 12-digit AWS Account ID (Required for unique bucket naming)"
  type        = string
  
  validation {
    condition     = can(regex("^\\d{12}$", var.account_id))
    error_message = "The account_id must be a 12-digit number."
  }
}

variable "project_name" {
  description = "Project name used for tagging"
  type        = string
  default     = "rankhex"
}