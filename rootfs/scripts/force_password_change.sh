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