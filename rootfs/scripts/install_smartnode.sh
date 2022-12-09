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

# Install the Smartnode
su -c "/home/$USER/bin/rocketpool s i -d -y" $USER
/home/$USER/bin/rocketpool --allow-root -c /home/$USER/.rocketpool s d -y

# Use legacy iptables implementation which Docker requires
update-alternatives --set iptables /usr/sbin/iptables-legacy