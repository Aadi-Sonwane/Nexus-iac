# =================================================================
# Stage: Prelive
# Layer: Infrastructure
# File: provider.tf
# Description: AWS Provider and Remote State Backend Configuration
# =================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" 
    }
  }

  # Using local backend for initial deployment. 
  # Move to S3 + DynamoDB when collaborating with a team.
  backend "local" {
    path = "terraform.tfstate"
  }


  # --- PRODUCTION BACKEND (S3 + DynamoDB) ---
  # NOTE: To use this, you must first create an S3 bucket and DynamoDB table manually.
  # This prevents "State Overlap" if multiple developers run terraform at once.
  
  /*
  backend "s3" {
    bucket         = "${var.project_name}-terraform-state-prelive"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-id" # Prevents concurrent state changes
  }
  */
}

provider "aws" {
  region = var.region

  # Default Tags: Automatically tags EVERY resource created in this stage
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "prelive"
      Owner       = "Aditya Sonwane"
      ManagedBy   = "Terraform"
    }
  }
}