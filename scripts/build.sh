#!/bin/bash

CMD=`realpath $0`
SCRIPTS_DIR=`dirname $CMD`
TOP_DIR=$(realpath $SCRIPTS_DIR/..)
echo "TOP DIR = $TOP_DIR"
CONFIG_BOARDS_DIR=$TOP_DIR/configs/boards
BUILD_DIR=$TOP_DIR/build
[ ! -d "$BUILD_DIR" ] && mkdir -p $BUILD_DIR/overlays $BUILD_DIR/overlays/packages $BUILD_DIR/recipes $BUILD_DIR/scripts

cleanup() {
    rm -rf $BUILD_DIR
}
trap cleanup EXIT

usage() {
    echo "====USAGE: build.sh -c <cpu> -b <board> -m <model> -d <distro>  -v <variant> -a <arch> -f <format> [-0]===="
    echo "Specify -0 to disable debug-shell, useful for automated build."
    echo "Options:"
    echo "  ./build.sh -c rk3308 -b rockpi-s -m debian -d buster -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3308 -b rockpi-s -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3399 -b rockpi-4b -m debian -d buster -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3399 -b rockpi-4b -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3399 -b rockpi-4cplus -m debian -d buster -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3399 -b rockpi-4cplus -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b radxa-cm3-io -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b radxa-cm3-io -m debian -d buster -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b radxa-cm3-io -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b radxa-e23 -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b radxa-e23 -m debian -d buster -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b radxa-e23 -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b rock-3c -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3566 -b rock-3c -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b radxa-e25 -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b radxa-e25 -m debian -d buster -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b radxa-e25 -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b rock-3a -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b rock-3a -m debian -d buster -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b rock-3a -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b rock-3b -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b rock-3b -m debian -d buster -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3568 -b rock-3b -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3588 -b rock-5b -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3588 -b rock-5b -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3588s -b radxa-nx5 -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3588s -b radxa-nx5 -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c rk3588s -b rock-5a -m debian -d bullseye -v xfce4 -a arm64 -f gpt"
    echo "  ./build.sh -c rk3588s -b rock-5a -m ubuntu -d focal -v server -a arm64 -f gpt"
    echo "  ./build.sh -c s905y2 -b radxa-zero -m debian -d buster -v xfce4 -a arm64 -f mbr"
    echo "  ./build.sh -c s905y2 -b radxa-zero -m ubuntu -d focal -v server -a arm64 -f mbr"
    echo "  ./build.sh -c a311d -b radxa-zero2 -m debian -d buster -v xfce4 -a arm64 -f mbr"
    echo "  ./build.sh -c a311d -b radxa-zero2 -m ubuntu -d focal -v server -a arm64 -f mbr"
}

DEBUG_SHELL=

while getopts "c:b:m:d:a:v:f:h:0" flag; do
    case $flag in
        c)
            CPU="$OPTARG"
            ;;
        b)
            BOARD="$OPTARG"
            ;;
        m)
            MODEL="$OPTARG"
            ;;
        d)
            DISTRO="$OPTARG"
            ;;
        a)
            ARCH="$OPTARG"
            ;;
        v)
            VARIANT="$OPTARG"
            ;;
        f)
            FORMAT="$OPTARG"
            ;;
        0)
            DEBUG_SHELL=-0
            ;;
	esac
done

if [ ! $CPU ] && [ ! $BOARD ] && [ ! $MODEL ] && [ ! $DISTRO ] && [ ! $VARIANT ]  && [ ! $ARCH ] && [ ! $FORMAT ]; then
    usage
    exit
fi

build_board() {
    echo "====Start to build $SUBBOARD board system image===="
    $SCRIPTS_DIR/debos-target-board.sh -c $CPU -b $BOARD -m $MODEL -d $DISTRO -v $VARIANT -a $ARCH -f $FORMAT $DEBUG_SHELL
    $SCRIPTS_DIR/compress-system-image.sh -c $CPU -b $BOARD -m $MODEL -d $DISTRO -v $VARIANT -a $ARCH -f $FORMAT
    echo "====Building $SUBBOARD board system image is done===="
}

clean_system_images() {
    echo "====Start to clean system images===="
    $SCRIPTS_DIR/clean-system-images.sh
    echo "====Cleaning system images is done===="
}

${CONFIG_BOARDS_DIR}/$CPU/config-$BOARD-$MODEL-$DISTRO-$VARIANT-$ARCH-$FORMAT.sh
build_board
clean_system_images
