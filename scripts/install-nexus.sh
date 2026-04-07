#!/bin/bash
# =================================================================
# Script: install-nexus.sh | RANKHEX PRODUCTION FINAL
# Description: Automated Nexus 3.69 Installation for AL2023
# =================================================================
set -e
exec > >(tee /var/log/nexus-install.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "--- [1] Storage: Self-Discovering EFS ID ---"
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
REGION=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/region)

# Query EFS ID based on Name tag containing 'rankhex'
EFS_ID=$(aws efs describe-file-systems --region $REGION --query 'FileSystems[?Tags[?Key==`Name` && contains(Value, `rankhex`)]].FileSystemId' --output text)

if [ -z "$EFS_ID" ] || [ "$EFS_ID" == "None" ]; then
    echo "ERROR: EFS ID not found via tags. Exiting."
    exit 1
fi

mkdir -p /opt/sonatype-work
dnf install -y amazon-efs-utils

if ! mountpoint -q /opt/sonatype-work; then
    mount -t efs -o tls $EFS_ID:/ /opt/sonatype-work
    if ! grep -q "$EFS_ID" /etc/fstab; then
        echo "$EFS_ID:/ /opt/sonatype-work efs _netdev,tls 0 0" >> /etc/fstab
    fi
fi

echo "--- [2] Environment: Installing Java 8 ---"
dnf install java-1.8.0-amazon-corretto -y
JAVA_8_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")

echo "--- [3] Download: Fetching Nexus OSS 3.69 ---"
cd /opt
wget -q "https://download.sonatype.com/nexus/3/nexus-3.69.0-02-java8-unix.tar.gz" -O nexus.tar.gz
tar -xvf nexus.tar.gz --exclude='sonatype-work'
rm -rf /opt/nexus && mv nexus-3.69.0-02 nexus
rm -f nexus.tar.gz

echo "--- [4] Configuration: Fixing Context Path (/nexus) ---"
mkdir -p /opt/sonatype-work/nexus3/etc
echo "nexus-context-path=/nexus" > /opt/sonatype-work/nexus3/etc/nexus.properties
sed -i 's|# nexus-context-path=/|nexus-context-path=/nexus|g' /opt/nexus/etc/nexus-default.properties
echo -e "run_as_user=\"nexus\"\nINSTALL4J_JAVA_HOME=\"$JAVA_8_HOME\"" > /opt/nexus/bin/nexus.rc

echo "--- [5] Permissions ---"
if ! id "nexus" &>/dev/null; then
    useradd -r -u 200 -m -c "nexus role account" -d /opt/sonatype-work -s /sbin/nologin nexus
fi
chown -R nexus:nexus /opt/nexus /opt/sonatype-work

echo "--- [6] Service: Creating SystemD Unit ---"
cat <<EOF > /etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target remote-fs.target
[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Group=nexus
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable nexus
systemctl start nexus