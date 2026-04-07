# =================================================================
# Stage: Prelive
# Layer: Application
# File: terraform.tfvars
# Description: Specific compute values for the Prelive server
# =================================================================

# --- Project Identifiers ---
project_name = "trainwithats"
region       = "ap-south-1"

# --- Compute Configuration ---
# t3.medium provides 4GB of RAM, essential for the Nexus JVM
instance_type = "t3.medium"

# --- Ownership & Tagging ---
owner = "Aditya Sonwane"

# --- Optional AMI Override ---
# Leave as null to use the latest Amazon Linux 2023 from data.tf
# ami_id = "ami-0abcdef1234567890"