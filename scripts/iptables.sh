#!/bin/bash
# =================================================================
# Script: iptables.sh
# Description: OS-level firewall hardening for the Nexus instance.
# Target OS: Amazon Linux 2023
# =================================================================

set -e

echo "--- [1/6] Installing Iptables Services ---"
dnf install -y iptables-services

echo "--- [2/6] Flushing Existing Rules ---"
iptables -F
iptables -X

echo "--- [3/6] Setting Default Policies (Drop by Default) ---"
# Production standard: Close everything, then open only what is needed
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

echo "--- [4/6] Allowing Essential Traffic ---"
# 1. Allow Loopback (Internal communication)
iptables -A INPUT -i lo -j ACCEPT

# 2. Allow Established and Related connections (Responses to outgoing traffic)
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# 3. Allow SSH (Port 22) - restricted to internal VPC/Bastion later via SG
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# 4. Allow Nexus (Port 8081) - traffic coming from ALB/NLB
iptables -A INPUT -p tcp --dport 8081 -j ACCEPT

# 5. Allow Docker Registry (Port 5000) - If using Nexus as a Docker Hub
iptables -A INPUT -p tcp --dport 5000 -j ACCEPT

echo "--- [5/6] Saving Rules for Persistence ---"
# Ensures rules are re-applied automatically if the EC2 restarts
systemctl enable iptables
service iptables save

echo "--- [6/6] Verifying Current Rules ---"
iptables -L -n -v

echo "--- Iptables Hardening Complete ---"