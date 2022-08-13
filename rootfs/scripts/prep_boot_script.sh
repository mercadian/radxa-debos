#!/bin/bash

set -eo pipefail

BOARD=$1

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

# Move extlinux
mv /boot/extlinux /boot/extlinux_bak

# Append the kernel and initrd selection to uEnv.txt
# echo "rootuuid=`cat /etc/kernel/cmdline | cut -d "=" -f 3`" >> /boot/uEnv.txt

