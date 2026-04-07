# =================================================================
# Module: app | File: iam.tf
# Description: IAM Role with specific access to S3, EFS, and SSM
# =================================================================

resource "aws_iam_role" "nexus_role" {
  name = "${var.project_name}-${var.env}-nexus-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}
resource "aws_iam_role_policy" "nexus_policy" {
  name = "${var.project_name}-${var.env}-nexus-policy"
  role = aws_iam_role.nexus_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # 1. S3 Discovery & Data Access (COMBINED FIX)
      {
        Effect   = "Allow"
        Action   = [
          "s3:ListAllMyBuckets",
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:HeadBucket",
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObjectTagging",
          "s3:GetObjectTagging"
        ]
        Resource = [
          "arn:aws:s3:::${var.s3_bucket_id}",
          "arn:aws:s3:::${var.s3_bucket_id}/*",
          "*" # Needed for ListAllMyBuckets and GetBucketLocation verification
        ]
      },
      # 2. EFS Mounting & Writing (Specific to your EFS ID)
      {
        Effect   = "Allow"
        Action   = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = "arn:aws:elasticfilesystem:${var.region}:${var.account_id}:file-system/${var.efs_id}"
      },
      # 3. EFS Discovery
      {
        Effect   = "Allow"
        Action   = ["elasticfilesystem:DescribeFileSystems"]
        Resource = "*"
      },
      # 4. Logging and Monitoring
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_instance_profile" "nexus_profile" {
  name = "${var.project_name}-${var.env}-nexus-profile"
  role = aws_iam_role.nexus_role.name
}

# Attach AmazonSSMManagedInstanceCore for browser-based terminal access
resource "aws_iam_role_policy_attachment" "nexus_ssm" {
  role       = aws_iam_role.nexus_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}