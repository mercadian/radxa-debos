#!/bin/bash

set -eo pipefail

if [[ "$(id -u)" -ne "0" ]]; then
     echo "This script requires root."
     exit 1
fi

# Variables
USER="rock"

# Make the rock user's password expire so it must be changed on the next boot
passwd -e $USER

# Disable automatic login to the debug console and prevent it from getting reinstated with a package upgrade down the line
dpkg-divert --divert /usr/lib/systemd/system/serial-getty@.service.orig-rock --rename /usr/lib/systemd/system/serial-getty@.service
cp /usr/lib/systemd/system/serial-getty@.service.orig-rock /usr/lib/systemd/system/serial-getty@.service
sed -i 's/--autologin root //g' /usr/lib/systemd/system/serial-getty@.service