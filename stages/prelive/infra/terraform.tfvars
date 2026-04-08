# =================================================================
# Stage: Prelive | File: terraform.tfvars
# Description: Environment-specific values for RankHex Networking
# =================================================================

# --- Core Identifiers ---
project_name = "trainwithats"
region       = "ap-south-1"
account_id   = "6788998888" # <-- DOUBLE CHECK THIS IN AWS CONSOLE
domain_name  = "trainwithats.online"

# --- Networking Layout (10.10.0.0/16 Supernet) ---
vpc_cidr = "10.10.0.0/16"

# Public Subnets: Reserved for ALBs and NAT Gateways
public_subnets = [
  "10.10.1.0/24", 
  "10.10.2.0/24"
]

# Private Subnets: Reserved for Nexus App Server and EFS Storage
private_subnets = [
  "10.10.4.0/24", 
  "10.10.5.0/24"
]

# High Availability: Spread across two Availability Zones
azs = [
  "ap-south-1a", 
  "ap-south-1b"
]