#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
     echo "This script requires root."
     exit 1
fi

# Variables
USER="rock"

# Add the Docker repo
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker and docker-compose
DEBIAN_FRONTEND=noninteractive apt update -qq > /dev/null
DEBIAN_FRONTEND=noninteractive apt install docker-ce docker-ce-cli docker-compose-plugin containerd.io -qq -y> /dev/null
usermod -aG docker $USER

# Download the Smartnode CLI
mkdir /home/$USER/bin
wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-arm64 -O /home/$USER/bin/rocketpool
chmod +x /home/$USER/bin/rocketpool
chown -R $USER:$USER /home/$USER/bin

# Install the Smartnode and the update tracker
su -c "/home/$USER/bin/rocketpool s i -d -y" $USER
/home/$USER/bin/rocketpool --allow-root -c /home/$USER/.rocketpool s d -y

# Use legacy iptables implementation which Docker requires
update-alternatives --set iptables /usr/sbin/iptables-legacy

# Set up iptable_filter, which ufw requires
cat <<'EOF' >> /etc/modules
iptable_filter
EOF

# Set up ufw on first-boot since it can't actually run in the image builder;
# It requires a kernel module that the builder doesn't load since it's not using the actual Radxa kernel
cat <<'EOF' >> /etc/first_boot
ufw default deny incoming comment 'Deny all incoming traffic'
ufw allow 22/tcp comment 'Allow SSH'
ufw allow 30303/tcp comment 'Execution client port, standardized by Rocket Pool'
ufw allow 30303/udp comment 'Execution client port, standardized by Rocket Pool'
ufw allow 9001/tcp comment 'Consensus client port, standardized by Rocket Pool'
ufw allow 9001/udp comment 'Consensus client port, standardized by Rocket Pool'
ufw allow 3100/tcp comment 'Allow grafana from anywhere'
ufw allow from 172.16.0.0/12 to any port 9103 comment 'Allow prometheus access to node-exporter'
ufw enable
EOF

# Set up unattended-upgrades
cat <<'EOF' > /etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::AutocleanInterval "7";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-New-Unused-Dependencies "true";

# This is the most important choice: auto-reboot.
# This should be fine since Rocketpool auto-starts on reboot.
# Uncomment the lines below (remove the # from the front) to enable auto-reboot.
# It's disabled by default on the Proteus.

# Unattended-Upgrade::Automatic-Reboot "true";
# Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF

# Set up fail2ban
cat <<'EOF' > /etc/fail2ban/jail.d/ssh.local
[sshd]
enabled = true
banaction = ufw
port = 22
filter = sshd
logpath = %(sshd_log)s
maxretry = 5
EOF
