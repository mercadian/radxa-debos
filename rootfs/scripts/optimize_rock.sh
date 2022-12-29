#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
     echo "This script requires root."
     exit 1
fi

# Set the CPU governor to performance so the CPU always runs with the max core speeds
echo 'GOVERNOR="performance"' > /etc/default/cpufrequtils

# Create the service for setting the DMC governor to performance on startup
cat > /etc/systemd/system/dmc-governor.service <<EOF
[Unit]
Description=Sets the DMC (memory controller) governor to "performance"
After=default.target

[Service]
Type=oneshot
ExecStart=/bin/sh -c 'echo "performance" > /sys/class/devfreq/dmc/governor'

[Install]
WantedBy=default.target

EOF

systemctl enable dmc-governor.service