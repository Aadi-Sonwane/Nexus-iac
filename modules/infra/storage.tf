# =================================================================
# Module: infra | File: storage.tf
# Description: Persistent Storage layer (S3 for Blobs, EFS for Config)
# =================================================================

# --- 1. S3 Bucket for Nexus Blob Store ---
resource "aws_s3_bucket" "nexus_blobs" {
  bucket = "${var.project_name}-${var.env}-nexus-blobs-${var.account_id}"

  # Protection against accidental deletion
  lifecycle {
    prevent_destroy = false 
  }

  tags = {
    Name        = "${var.project_name}-${var.env}-nexus-blobs"
    Environment = var.env
  }
}

# Cost Optimization: Clean up failed large artifact uploads after 7 days
resource "aws_s3_bucket_lifecycle_configuration" "blobs_lifecycle" {
  bucket = aws_s3_bucket.nexus_blobs.id

  rule {
    id     = "abort-failed-uploads"
    status = "Enabled"
    filter {}
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Block all public access for security compliance
resource "aws_s3_bucket_public_access_block" "blobs_private" {
  bucket = aws_s3_bucket.nexus_blobs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --- 2. EFS File System (The "Memory" for Nexus Config) ---
resource "aws_efs_file_system" "nexus_data" {
  creation_token = "${var.project_name}-${var.env}-efs"
  encrypted      = true
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"

  tags = {
    Name = "${var.project_name}-${var.env}-nexus-efs"
  }
}

# --- 3. EFS Mount Targets (High Availability across AZs) ---
resource "aws_efs_mount_target" "nexus" {
  count           = length(var.private_subnets)
  file_system_id  = aws_efs_file_system.nexus_data.id
  subnet_id       = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.efs_sg.id]
}

# --- 4. EFS Access Point (Ensures consistent ownership) ---
resource "aws_efs_access_point" "nexus_root" {
  file_system_id = aws_efs_file_system.nexus_data.id

  # Forces all files to be owned by Nexus User (UID 200)
  posix_user {
    gid = 200
    uid = 200
  }

  root_directory {
    path = "/nexus-data"
    creation_info {
      owner_gid   = 200
      owner_uid   = 200
      permissions = "755"
    }
  }
}