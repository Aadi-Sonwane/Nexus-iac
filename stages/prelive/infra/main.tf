# =================================================================
# Stage: Prelive | Layer: Infrastructure | File: main.tf
# Description: Instantiates the Networking and Storage for Prelive
# =================================================================

# --- Module Call: The Foundation ---
module "prelive_infra" {
  source = "../../../modules/infra"

  # Metadata
  project_name = var.project_name
  env          = "prelive"
  region       = var.region
  account_id   = var.account_id

  # Networking (Variables passed from terraform.tfvars)
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs

  # DNS
  domain_name = var.domain_name
}