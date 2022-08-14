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

# Swap the DTBs
mv /boot${DTB_PATH}/rockchip/rk3588-rock-5b.dtb /boot${DTB_PATH}/rockchip/rk3588-rock-5b.dtb_bak
cp /boot${DTB_PATH}/rockchip/rk3588-rock-5b-v11.dtb /boot${DTB_PATH}/rockchip/rk3588-rock-5b.dtb

echo "Replaced main DTB with v11 DTB"