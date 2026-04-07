# =================================================================
# Module: app
# File: cloud_init.tf
# Description: Orchestrates the execution of all automation scripts
# =================================================================

data "cloudinit_config" "nexus_setup" {
  gzip          = true
  base64_encode = true

  # --- Part 1: Time Synchronization ---
  part {
    filename     = "amazon-time-sync.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../../scripts/amazon-time-sync.sh")
  }

  # --- Part 2: EFS Mounting ---
  part {
    filename     = "setup-efs.sh"
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/../../scripts/setup-efs.sh", {
      efs_id = var.efs_id,
      region = var.region
    })
  }

  # --- Part 3: Iptables Hardening ---
  part {
    filename     = "iptables.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../../scripts/iptables.sh")
  }

  # --- Part 4: CloudWatch Agent Configuration ---
  part {
    filename     = "cw-config.json"
    content_type = "text/cloud-config"
    merge_type   = "list(append)+2"
    content      = <<EOF
#cloud-config
write_files:
  - path: /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
    owner: root:root
    permissions: '0644'
    content: |
${indent(6, templatefile("${path.module}/../../scripts/templates/cw-agent-config.json.tftpl", { env = var.env }))}
EOF
  }

  # --- Part 5: Install CloudWatch Agent ---
  part {
    filename     = "cloudwatch-agent.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../../scripts/cloudwatch-agent.sh")
  }

  # --- Part 6: Install Nexus 3 (The Final Step) ---
  part {
    filename     = "install-nexus.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/../../scripts/install-nexus.sh")
  }
}
