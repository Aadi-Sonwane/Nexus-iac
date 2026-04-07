# =================================================================
# Stage: Prelive
# Layer: Application
# File: provider.tf
# Description: AWS Provider and Remote State Backend for App Layer
# =================================================================

terraform {
  # Minimum version to support the 'cloudinit_config' and 'templatefile'
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Required for the cloud_init logic in the app module
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.0"
    }
  }

  # --- PRODUCTION BACKEND (S3 + DynamoDB) ---
  # Using a different 'key' than the infra layer to prevent state overlap.
  /*
  backend "s3" {
    bucket         = "${var.project_name}-terraform-state-prelive"
    key            = "app/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-id"
  }
  */
}

provider "aws" {
  region = var.region

  # Standard Tags: Applied to the ASG, Launch Template, and IAM Roles
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "prelive"
      Owner       = var.owner
      ManagedBy   = "Terraform"
      Layer       = "Application"
    }
  }
}