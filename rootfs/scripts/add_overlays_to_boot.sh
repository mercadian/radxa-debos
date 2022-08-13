#!/bin/bash

set -eo pipefail

BOARD=$1

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

# Get the line of the "devicetreedir" line in extlinux.conf
LINE_NUMBER=$(awk '/devicetreedir/{print NR}' /boot/extlinux/extlinux.conf)

# Get the DTB path
DTB_PATH=$(sed -n ${LINE_NUMBER}p /boot/extlinux/extlinux.conf | tr -s ' ' | cut -d ' ' -f 3)

# Put the ftdoverlays line in
sed -e "$((LINE_NUMBER+1)) i \    fdtoverlays ${DTB_PATH}/rockchip/overlay/sta-led-overlay.dtbo" -i /boot/extlinux/extlinux.conf

# Print it
echo "I: show /boot/extlinux/extlinux.conf"
cat /boot/extlinux/extlinux.conf