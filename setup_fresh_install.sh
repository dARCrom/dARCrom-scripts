#!/bin/bash

# A quickly hacked shell script to setup all required dependencies for a new build server. (not yet ready for public usage!!)
# This script should be used once you logged in to your machine for the first time after a fresh/new installation.
#
# Inclues:
# - repo / ccache
# - AOSP build requirements
#
#
# Authors:
# - Patrick Jung <patrick.pddstudio@gmail.com>
#

clear
echo "Updating packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install java jre/jdk
echo "Installing java runtime..."
sudo apt-get install openjdk-8-jdk -y
sudo apt-get install openjdk-8-jre -y

# Install build requirements for AOSP
echo "Installing AOSP build requirements"
sudo apt-get install git-core gnupg flex bison gperf build-essential \
  zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  libgl1-mesa-dev libxml2-utils xsltproc unzip

sudo apt-get install git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev \
		squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev openjdk-8-jre openjdk-8-jdk pngcrush \
		schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
		gcc-multilib liblz4-* pngquant ncurses-dev texinfo gcc gperf patch libtool \
		automake g++ gawk subversion expat libexpat1-dev python-all-dev bc libcloog-isl-dev \
		libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* \
		liblzma* w3m android-tools-adb maven ncftp htop

echo "Setting up ccache"
export USE_CCACHE=1
export CCACHE_DIR=$HOME/.ccache
prebuilts/misc/linux-x86/ccache/ccache -M 100G
echo -e "export USE_CCACHE=1" >> $HOME/.bashrc
source $HOME/.bashrc

echo "Setting up repo"
mkdir $HOME/bin
export PATH=$HOME/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
chmod a+x $HOME/bin/repo

echo "Everything done!"
exit 0