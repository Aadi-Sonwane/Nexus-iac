#!/bin/bash
# =================================================================
# Script: amazon-time-sync.sh
# Description: Configures Chrony to use the Amazon Time Sync Service
# Target OS: Amazon Linux 2023 / RHEL 9
# =================================================================

set -e

echo "--- [1/4] Installing Chrony ---"
dnf install -y chrony

echo "--- [2/4] Configuring Amazon Time Sync Service ---"
# The IP 169.254.169.123 is a link-local address accessible from any EC2
if ! grep -q "169.254.169.123" /etc/chrony.conf; then
  sed -i '1i server 169.254.169.123 prefer iburst minpoll 4 maxpoll 4' /etc/chrony.conf
fi

echo "--- [3/4] Enabling and Starting Chrony ---"
systemctl enable chronyd
systemctl restart chronyd

echo "--- [4/4] Verifying Synchronization ---"
# Check if the Amazon source is being used (indicated by a '*' or '+')
chronyc sources -v

echo "--- Time Sync Configuration Complete ---"