#!/bin/bash
# =================================================================
# Script: setup-efs.sh | RankHex Production
# =================================================================
set -e
exec > >(tee /var/log/setup-efs.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- [1/5] Installing Amazon EFS Utils ---"
dnf install -y amazon-efs-utils

echo "--- [2/5] Creating Nexus Work Directory ---"
mkdir -p /opt/sonatype-work

echo "--- [3/5] Mounting EFS File System ---"
# We use the variable injected by Terraform's templatefile function
if mountpoint -q /opt/sonatype-work; then
    echo "Directory is already mounted. Refreshing..."
else
    # Mounting with TLS for encryption in transit
    mount -t efs -o tls ${efs_id}:/ /opt/sonatype-work
fi

echo "--- [4/5] Updating /etc/fstab for Persistence ---"
if ! grep -q "/opt/sonatype-work" /etc/fstab; then
    echo "${efs_id}:/ /opt/sonatype-work efs defaults,_netdev,tls 0 0" >> /etc/fstab
fi

echo "--- [5/5] Setting Initial Permissions ---"
# Nexus UID 200 must own this folder for the app to start
chown -R 200:200 /opt/sonatype-work
echo "--- EFS Setup Complete ---"