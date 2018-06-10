#!/usr/bin/env bash

# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# SPDX-License-Identifier: GPL-3.0-only #

if [ ! -d utils ]; then
    echo "Run this script from the root of the repository"
    exit 1
fi

UBUNTU_14_PACKAGES="git-core libesd0-dev libwxgtk2.8-dev curl schedtool binutils-static figlet libesd0-dev"
UBUNTU_16_PACKAGES="libesd0-dev"
CORE_PACKAGES="python gnupg flex bison gperf libsdl1.2-dev squashfs-tools build-essential zip libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk
pngcrush schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev g++-multilib lib32z1-dev lib32ncurses5-dev gcc-multilib liblz4-* pngquant
ncurses-dev texinfo gcc gperf patch libtool automake g++ gawk subversion expat libexpat1-dev python-all-dev bc libcloog-isl-dev libcap-dev
autoconf libgmp-dev build-essential pkg-config libmpc-dev libmpfr-dev lzma* liblzma* w3m adb fastboot maven ncftp htop imagemagick
libssl-dev clang cmake"
PACKAGES=""

LSB_RELEASE=$(lsb_release -d)

if [[ ${LSB_RELEASE} =~ "Mint 19" || ${LSB_RELEASE} =~ "Ubuntu 18" ]]; then
    PACKAGES="${CORE_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Ubuntu 16" ]]; then
    PACKAGES="${CORE_PACKAGES} ${UBUNTU_16_PACKAGES}"
elif [[ ${LSB_RELEASE} =~ "Ubuntu 14" ]]; then
    PACKAGES="${CORE_PACKAGES} ${UBUNTU_14_PACKAGES}"
fi

apt install "${PACKAGES}"

if [[ ! "$(which adb)" == "" ]]; then
    echo -e "Setting up some stuff for adb!"
    sudo curl --create-dirs -L -o /etc/udev/rules.d/51-android.rules -O -L https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules
    sudo chmod 644 /etc/udev/rules.d/51-android.rules
    sudo chown root /etc/udev/rules.d/51-android.rules
    sudo systemctl restart udev
    adb kill-server
    sudo killall adb
fi

if [ "$(command -v make)" ]; then
    makeversion="$(make -v | head -1 | awk '{print $3}')";
    if [ "${makeversion}" != "4.2.1" ]; then
        echo "Installing make 4.2.1 instead of ${makeversion}";
	sudo install utils/make /usr/local/bin/;
    fi
fi

echo "Installing repo"
sudo curl --create-dirs -L -o /usr/local/bin/repo -O -L https://github.com/akhilnarang/repo/raw/master/repo
sudo chmod a+x /usr/local/bin/repo

bash ./setup/ccache.sh;
bash ./setup/ninja.sh;
