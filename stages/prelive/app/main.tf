# =================================================================
# Stage: Prelive
# Layer: Application
# File: main.tf
# Description: Deploys the Nexus Server using the App Module
# =================================================================

# --- Module Call: The Application Server ---
module "prelive_nexus" {
  source = "../../../modules/app"

  # Metadata
  project_name = var.project_name
  env          = "prelive"
  region       = var.region
  account_id   = data.aws_caller_identity.current.account_id

# Infrastructure Handshake (Sourced from data.tf / remote_state)
  vpc_id           = data.terraform_remote_state.infra.outputs.vpc_id
  private_subnets  = data.terraform_remote_state.infra.outputs.private_subnets
  app_sg_id        = data.terraform_remote_state.infra.outputs.app_sg_id
  target_group_arn = data.terraform_remote_state.infra.outputs.nexus_tg_arn
  nexus_ec2_tg_arn = data.terraform_remote_state.infra.outputs.nexus_ec2_tg_arn
  efs_id           = data.terraform_remote_state.infra.outputs.efs_id
  s3_bucket_id     = data.terraform_remote_state.infra.outputs.s3_bucket_id

  # Compute Configuration
  ami_id        = data.aws_ami.latest_al2023.id
  instance_type = var.instance_type

  # NOTE: cloud_init is now handled internally by the module 
  # to prevent circular dependency errors.
}