# =================================================================
# Stage: Prelive
# Layer: Application
# File: data.tf
# Description: Fetches existing infrastructure IDs and AMI metadata
# =================================================================

# --- 1. Remote State Lookup (The Bridge) ---
# This "reads" the terraform.tfstate file from the infra folder
# so the App layer knows where the VPC and EFS are located.
data "terraform_remote_state" "infra" {
  backend = "local" # Change to "s3" if you move to a remote backend

  config = {
    path = "../infra/terraform.tfstate"
  }
}

# --- 1. Remote State Lookup (S3 Backend) ---
# data "terraform_remote_state" "infra" {
#   backend = "s3" # Changed from "local"

#   config = {
#     bucket = "rankhex-terraform-state-012345678901"
#     key    = "prelive/infra/terraform.tfstate" # Points to infra's S3 key
#     region = "ap-south-1"
#   }
# }

# --- 2. Dynamic AMI Lookup ---
# Instead of hardcoding an AMI ID (which changes often), we fetch the
# latest official "Amazon Linux 2023" image automatically.
data "aws_ami" "latest_al2023" {
  most_recent = true
  owners      = ["137112412989"] # Official Amazon Account ID

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# --- 3. Current AWS Context ---
# Useful for getting the Account ID or Region dynamically
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}