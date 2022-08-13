#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
     echo "This script requires root."
     exit 1
fi

# Variables
USER="rock"
DOCKER_COMPOSE_VERSION="1.29.2"

# Grab the docker repo key - note that apt-key is deprecated
wget -O- "https://download.docker.com/linux/debian/gpg" | sudo apt-key add -
#wget -O- "https://download.docker.com/linux/debian/gpg" | gpg --dearmor > /usr/share/keyrings/docker-archive-keyring.gpg

# Install Docker and docker-compose
DEBIAN_FRONTEND=noninteractive apt update -qq > /dev/null
DEBIAN_FRONTEND=noninteractive apt install docker-ce docker-ce-cli containerd.io -qq -y> /dev/null
pip3 install --upgrade --quiet docker-compose==$DOCKER_COMPOSE_VERSION
usermod -aG docker $USER

# Install the Smartnode
mkdir /home/$USER/bin
wget https://github.com/rocket-pool/smartnode-install/releases/latest/download/rocketpool-cli-linux-arm64 -O /home/$USER/bin/rocketpool
chmod +x /home/$USER/bin/rocketpool 
su -c "/home/$USER/bin/rocketpool s i -d -y" $USER
/home/$USER/bin/rocketpool --allow-root -c /home/$USER/.rocketpool s d -y
