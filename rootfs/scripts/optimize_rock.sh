#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
     echo "This script requires root."
     exit 1
fi

# Set the CPU governor to performance so the CPU always runs with the max core speeds
echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils

# Create the service for setting the DMC governor to performance on startup
cat <<'EOF' > /etc/systemd/system/dmc-governor.service
[Unit]
Description=Sets the DMC (memory controller) governor to "performance"
After=default.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo "performance" > /sys/class/devfreq/dmc/governor'

[Install]
WantedBy=default.target
EOF

# Configure iwlwifi with stability improvements
cat <<'EOF' > /etc/modprobe.d/iwlwifi.conf
options iwlwifi 11n_disable=1 swcrypto=0 bt_coex_active=0 power_save=0
EOF

systemctl enable dmc-governor.service

# Set up the swap partition
mkswap -L swap ${IMAGE}-part2
UUID=$(swaplabel ${IMAGE}-part2 | grep ^UUID: | awk '{print $2}')
echo "UUID=${UUID} none swap pri=5 0 0" >> /etc/fstab

# Tune the swappiness parameters
cat <<'EOF' >> /etc/sysctl.conf

# Proteus settings for swap

vm.swappiness=4
vm.vfs_cache_pressure=120
vm.dirty_background_ratio=10
vm.dirty_ratio=20
vm.page-cluster=3
EOF

# Set up the Bluetooth blacklist for the Radxa A8
cat <<'EOF' >> /etc/modprobe.d/blacklist.conf
blacklist btusb
blacklist btrtl
blacklist btbcm
blacklist btintel
EOF
