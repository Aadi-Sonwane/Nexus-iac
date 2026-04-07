# =================================================================
# Module: app
# File: variables.tf
# Description: Input variables for the EC2, ASG, and IAM roles
# =================================================================

# --- Metadata ---

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "env" {
  description = "The deployment environment (prelive/live)"
  type        = string
}

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "account_id" {
  description = "The AWS Account ID"
  type        = string
}

# --- Infrastructure Handshakes (From Infra Module) ---
# --- Networking Handshake ---
variable "vpc_id" {
  description = "The ID of the VPC (required for internal data lookups)"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs where Nexus will reside"
  type        = list(string)
}

variable "app_sg_id" {
  description = "The Security Group ID for the Nexus instance"
  type        = string
}

variable "target_group_arn" {
  description = "The ARN of the Target Group to attach to the ASG. ALB Target Group (IP-type)"
  type        = string
}

variable "nexus_ec2_tg_arn" {
  description = "The ARN of the NLB Target Group for TCP traffic. NLB Target Group (Instance-type)"
  type        = string
}
variable "efs_id" {
  description = "The ID of the EFS File System"
  type        = string
}

variable "s3_bucket_id" {
  description = "The ID of the S3 Bucket for Nexus Blobs"
  type        = string
}

# --- Compute Configuration ---

variable "ami_id" {
  description = "The AMI ID for Amazon Linux 2023"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type (e.g., t3.medium)"
  type        = string
  default     = "t3.medium"
}

