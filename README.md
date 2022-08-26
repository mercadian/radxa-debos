# debos-radxa

## Introduction

This guide describes how to use debos-radxa, based on [debos](https://github.com/go-debos/debos), to generate Radxa system image.

## Supported boards and system images

* Radxa CM3 IO    : https://github.com/radxa-build/radxa-cm3-io/releases/latest
* Radxa E23       : https://github.com/radxa-build/radxa-e23/releases/latest
* Radxa E25       : https://github.com/radxa-build/radxa-e25/releases/latest
* Radxa Zero      : https://github.com/radxa-build/radxa-zero/releases/latest
* Radxa Zero 2    : https://github.com/radxa-build/radxa-zero2/releases/latest
* ROCK 3A         : https://github.com/radxa-build/rock-3a/releases/latest
* ROCK 3B         : https://github.com/radxa-build/rock-3b/releases/latest
* ROCK 5B         : https://github.com/radxa-build/rock-5b/releases/latest
* ROCK Pi 4B      : https://github.com/radxa-build/rockpi-4b/releases/latest
* ROCK Pi 4C Plus : https://github.com/radxa-build/rockpi-4cplus/releases/latest

## Build Host

### Required Packages for the Build Host

You must install essential host packages on your build host.
The following command installs the host packages on an Ubuntu distribution

<pre>
$ sudo apt-get install -y git user-mode-linux libslirp-helper
</pre>

### Install Docker Engine on Ubuntu

See Docker Docs [installing Docker Engineer on Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

## Use Git to Clone debos-radxa

<pre>
radxa@x86-64:~$ cd ~
radxa@x86-64:~$ git clone https://github.com/radxa/debos-radxa.git
</pre>

## Build Your Image

### Part One: Build image step by step

Launch `dev-shell` to get a shell inside debos docker.

<pre>
radxa@x86-64:~$ cd debos-radxa
radxa@x86-64:~/debos-radxa$ ./docker/dev-shell
Building Docker environment...
Sending build context to Docker daemon   2.56kB
Step 1/11 : FROM debian:testing
 ---> fb444549e96f
...
...
...
Step 11/11 : ENV USER=root     HOME=/root
 ---> Using cache
 ---> bc195e420707
Successfully built bc195e420707
Successfully tagged debos-radxa:1
Enter Docker container...
root@terra:~/debos-radxa#
</pre>

Launch `./build.sh` to get build options.

<pre>
root@terra:~/debos-radxa# ./build.sh
TOP DIR = /build/stephen/debos-radxa
====USAGE: ./build.sh -b <board> -m <model>====
Board list:
    radxa-cm3-io
    radxa-e23
    radxa-e25
    radxa-nx5
    radxa-zero
    radxa-zero2
    rockpi-4b
    rockpi-4cplus
    rock-3a
    rock-3b
    rock-3c
    rock-5a
    rock-5b

Model list:
    debian
    ubuntu
</pre>

Start to build image such as rock-5b-ubuntu-focal-server-arm64-gpt image.

<pre>
root@terra:~/debos-radxa# ./build.sh -b rock-5b -m ubuntu
TOP DIR = /home/radxa/debos-radxa
====Start to build  board system image====
TOP DIR = /home/radxa/debos-radxa
====Start to preppare workspace directory, build====
...
...
...
====debos rock-5b-ubuntu-focal-server-arm64-gpt end====
TOP DIR = /home/radxa/debos-radxa
 System image rock-5b-ubuntu-focal-server-arm64-20220308-1107-gpt.img is generated. See it in /home/radxa/debos-radxa/output
/home/radxa/debos-radxa
====Building  board system image is done====
====Start to clean system images====
TOP DIR = /home/radxa/debos-radxa
I: show all system images:
total 329092
drwxr-xr-x  2 root root      4096 Mar  8 11:09 .
drwxrwxr-x 10 1002 1002      4096 Mar  8 11:08 ..
-rw-r--r--  1 root root    139442 Mar  8 11:07 rock-5b-ubuntu-focal-server-arm64-20220308-1107-gpt.img.bmap
-rw-r--r--  1 root root        90 Mar  8 11:07 rock-5b-ubuntu-focal-server-arm64-20220308-1107-gpt.img.md5.txt
-rw-r--r--  1 root root 336828856 Mar  8 11:07 rock-5b-ubuntu-focal-server-arm64-20220308-1107-gpt.img.xz
====Cleaning system images is done====
root@terra:~/debos-radxa#
</pre>

The generated system images will be copied to `./output` direcotry.

### Part Two: Build image with one line command

#### Example one of building rock-3a-ubuntu-focal-server-arm64-gpt image

In this example we will build ROCK 3A's system image with full options:

<pre>
radxa@x86-64:~$ cd ~
radxa@x86-64:~$ cd debos-radxa/
radxa@x86-64:~/debos-radxa$
radxa@x86-64:~/debos-radxa$ docker run --rm --interactive --tty --device /dev/kvm --user $(id -u) --security-opt label=disable \
--workdir $PWD --mount "type=bind,source=$PWD,destination=$PWD" --entrypoint ./build.sh godebos/debos \
-c rk3568 -b rock-3a -m ubuntu -d focal -v server -a arm64 -f gpt
</pre>

#### Example two of building radxa-zero2-ubuntu-focal-server-arm64-mbr image

You can also build supported configuration with the following commands:

<pre>
radxa@x86-64:~$ cd ~
radxa@x86-64:~$ cd debos-radxa/
radxa@x86-64:~/debos-radxa$ docker run --rm --interactive --tty --device /dev/kvm --user $(id -u) --security-opt label=disable \
--workdir $PWD --mount "type=bind,source=$PWD,destination=$PWD" --entrypoint scripts/build-supported-configuration.sh \
godebos/debos -m ubuntu -b radxa-zero2
</pre>

The generated system images will be copied to `./output` direcotry. You can specify different configuration in the 3rd line.

Note: GitHub Actions uses some different options for `docker run` due to their runners do not support nested virtualization (i.e. no `/dev/kvm`). In that's your case you need to specify `--tmpfs /dev/shm:rw,nosuid,nodev,exec,size=4g` instead of `--device /dev/kvm`. It also uses a wrapper script to only build the supported configurations.

## How to debug errors

Launch `dev-shell` to get a shell inside debos docker. You can then run `build.sh` to monitor the build status. debos mounts root partition at `/scratch/mnt`, and boot partition is mounted at `/scratch/mnt/boot`. You can also `chroot /scratch/mnt` to examine the file system.

Currently `dev-shell` uses a custom docker image to build, so your result might be different from GitHub build. If you want to reproduce GitHub build please use the command from Usage section.

## Add support for new boards

`./boards/*/packages.list.d/*.list` are board-specific debos recipes.

`./rootfs/packages` contains additional packages.

## Default settings

* Default non-root user: rock (password: rock)
* Automatically load Bluetooth firmware after startup
* The first boot will resize root filesystem to use all available disk space
* SSH installed by default
* Hostname: board_name
