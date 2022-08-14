#!/bin/bash

set -eo pipefail

BOARD=$1

if [[ "$(id -u)" -ne "0" ]]; then
    echo "This script requires root."
    exit 1
fi

EXTLINUX_CONF="/boot/extlinux/extlinux.conf"

# Append the given arg to the kernel args in the boot file
append_kernel_arg() {
    # Get the number for each line that starts with "append", which is for kernel args
    LIST=$(awk '/^([[:space:]]*)append(.*)$/{print NR}' $EXTLINUX_CONF)

    for LINE_NUMBER in $LIST; do
        LINE_CONTENTS=$(sed -n ${LINE_NUMBER}p $EXTLINUX_CONF)

        # Check if the arg already exists
        if [[ "$LINE_CONTENTS" != *"$1"* ]]; then
            # If not, append it to the end of the line
            sed "${LINE_NUMBER} s/$/ $1/" -i $EXTLINUX_CONF
        fi
    done

}

# Ensure the fdtoverlays line is always present in the boot parameters
enforce_fdtoverlays() {
    # Get the list of "devicetreedir" lines in extlinux.conf
    LIST=$(awk '/^([[:space:]]*)devicetreedir(.*)$/{print NR}' $EXTLINUX_CONF)

    for LINE_NUMBER in $LIST; do
        DEVICETREEDIR_LINE_CONTENTS=$(sed -n ${LINE_NUMBER}p $EXTLINUX_CONF)
        OVERLAY_LINE=$((LINE_NUMBER+1))
        OVERLAY_LINE_CONTENTS=$(sed -n ${OVERLAY_LINE}p $EXTLINUX_CONF)

        # Check if the line after it is already an fdtoverlays line
        if [[ "$OVERLAY_LINE_CONTENTS" != *"fdtoverlays"* ]]; then
            # If not, put the fdtoverlays line in
            DTB_PATH=$(echo "$DEVICETREEDIR_LINE_CONTENTS" | tr -s ' ' | cut -d ' ' -f 3)
            sed -e "$OVERLAY_LINE i \    fdtoverlays ${DTB_PATH}/rockchip/overlay/sta-led-overlay.dtbo" -i $EXTLINUX_CONF
        fi
    done
}

# Force cgroups v1 for Docker compatibility
append_kernel_arg "systemd.unified_cgroup_hierarchy=0"

# Add the fdtoverlays line
enforce_fdtoverlays

# Print it
echo "I: show $EXTLINUX_CONF"
cat $EXTLINUX_CONF