#!/bin/bash

CMD=`realpath $0`
CONFIG_BOARD_DIR=`dirname $CMD`
TOP_DIR=$(realpath $CONFIG_BOARD_DIR/../../../)
echo "TOP DIR = $TOP_DIR"
BUILD_DIR=$TOP_DIR/build
[[ ! -d "$BUILD_DIR" ]] && mkdir -p $BUILD_DIR

# env
export CPU=rk3588
export BOARD=rock-5b
export MODEL=debian
export DISTRO=bullseye
export VARIANT=server
export ARCH=arm64
export FORMAT=gpt
export IMAGESIZE=5000MB

# Add pre-installed packages for target system
cat > $BUILD_DIR/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-${FORMAT}-packages.list <<EOF
radxa-add-overlay*.deb
rockchip-overlay*.deb
proteus-overlay_*_arm64.deb
linux-headers-5.10.66*.deb
linux-image-5.10.66*.deb
intel-wifibt-firmware*.deb
realtek-wifibt-firmware*.deb
resize-assistant*.deb
librga2_2.2.0-1_arm64.deb
librga2-dbgsym_2.2.0-1_arm64.deb
librga-dev_2.2.0-1_arm64.deb
librockchip-mpp1_1.5.0-1_arm64.deb
librockchip-mpp1-dbgsym_1.5.0-1_arm64.deb
librockchip-mpp-dev_1.5.0-1_arm64.deb
librockchip-vpu0_1.5.0-1_arm64.deb
librockchip-vpu0-dbgsym_1.5.0-1_arm64.deb
rockchip-mpp-demos_1.5.0-1_arm64.deb
rockchip-mpp-demos-dbgsym_1.5.0-1_arm64.deb
camera-engine-rkaiq*arm64.deb
EOF

# Add yaml variable
cat > $BUILD_DIR/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-${FORMAT}-variable.yaml <<EOF
{{- \$board := or .board "${BOARD}" -}}
{{- \$architecture := or .architecture "${ARCH}" -}}
{{- \$model :=  or .model "${MODEL}" -}}
{{- \$suite := or  .suite "${DISTRO}" -}}
{{- \$imagesize := or .imagesize "${IMAGESIZE}" -}}
{{- \$bootpartitionend := or .bootpartitionend "1081343S" -}}
{{- \$rootpartitionstart := or .rootpartitionstart "1081344S" -}}
{{- \$apt_repo := or .apt_repo "radxa" -}}

EOF

# Add images yaml
cat > $BUILD_DIR/${BOARD}-${MODEL}-${DISTRO}-${VARIANT}-${ARCH}-${FORMAT}-yaml.list <<EOF
00_architecture.yaml
01_debootstrap_debian.yaml
02_partitions_upstream.yaml
03_filesystem_deploy.yaml
20_packages_start.yaml
21_packages_debian_server.yaml
21_packages_smartnode.yaml
22_packages_end.yaml
70_system_common_setup.yaml
85_u_boot_rk35xx.yaml
86_install_smartnode.yaml
88_add_explicit_dtb.yaml
90_clean_rootfs.yaml
EOF
