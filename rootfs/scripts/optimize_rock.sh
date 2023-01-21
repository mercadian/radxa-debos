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
cat <<EOF > /etc/modprobe.d/iwlwifi.conf
options iwlwifi 11n_disable=1 swcrypto=0 bt_coex_active=0 power_save=0
EOF

systemctl enable dmc-governor.service