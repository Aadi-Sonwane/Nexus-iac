# =================================================================
# Folder: backend
# File: main.tf
# Description: Bootstraps the S3 Bucket and DynamoDB for Remote State
# =================================================================

provider "aws" {
  region = var.region
}

# 1. The S3 Bucket for State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "rankhex-terraform-state-${var.account_id}"
  
  # Prevent accidental deletion of the state bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "RankHex Terraform State"
    Environment = "Global"
  }
}

# 2. Enable Versioning (Crucial for state recovery)
resource "aws_s3_bucket_versioning" "state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "state_crypto" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. DynamoDB for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "rankhex-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
  }
}

output "state_bucket_name" {
  value = aws_s3_bucket.terraform_state.id
}