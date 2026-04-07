#!/bin/bash
# =================================================================
# Script: cloudwatch-agent.sh
# Description: Installs and starts the CloudWatch Agent for 
#              streaming Nexus logs and system metrics.
# Target OS: Amazon Linux 2023
# Variables: Injected via Cloud-init from the .tftpl file
# =================================================================

set -e

# Logging to user-data log
exec > >(tee /var/log/cloudwatch-setup.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- [1/4] Downloading Amazon CloudWatch Agent ---"
# Amazon Linux 2023 uses dnf/rpm
dnf install -y amazon-cloudwatch-agent

echo "--- [2/4] Applying CloudWatch Configuration ---"
# Note: The actual JSON content is written to this path by Terraform 
# during the cloud-init 'write_files' phase before this script runs.
# We will define the template file (cw-agent-config.json.tftpl) next.
CONFIG_PATH="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"

if [ -f "$CONFIG_PATH" ]; then
    echo "Configuration file found. Starting agent..."
else
    echo "ERROR: Configuration file not found at $CONFIG_PATH"
    exit 1
fi

echo "--- [3/4] Starting CloudWatch Agent Service ---"
# The fetch-config command initializes the agent with our custom JSON
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:$CONFIG_PATH

echo "--- [4/4] Enabling Agent on Boot ---"
systemctl enable amazon-cloudwatch-agent

echo "--- CloudWatch Agent Setup Complete ---"