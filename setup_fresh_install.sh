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

# Update system and packages
function update_system()
{
	echo "Updating packages..."
	sudo apt-get -y update
	sudo apt-get -y upgrade
}

# Add the missing java 8 ppa for Ubuntu 14.04 LTS
function add_java_ppa()
{
	sudo add-apt-repository -y ppa:openjdk-r/ppa
	sudo apt-get -y update
}

# Install java 8 development kit and runtime
function install_java()
{
	OS_VERSION=lsb_release -rs
	
	# Check the current system's version and add the missing java 8 package-ppa on Ubuntu 14.04 LTS
	if [[ $OS_VERSION == 14* ]]; then
		echo "An older version of Ubuntu was found: ${OS_VERSION}"
		echo "There is no Java 8 ppa available by default for this OS version."
		echo "Adding the missing java8-ppa: >> ppa:openjdk-r/ppa"
		add_java_ppa
	fi

	echo "Installing java runtime..."
	sudo apt-get -y install openjdk-8-jdk
	sudo apt-get -y install openjdk-8-jre
}

# In case multiple java versions are installed - set java 8 as default version
function update_java_alternatives()
{
	sudo update-alternatives --config java
	sudo update-alternatives --config javac
}

# Install required packages for android builds
function install_build_dependencies()
{
	echo "Installing AOSP build requirements"
	sudo apt-get -y install git-core gnupg flex bison gperf build-essential \
  			zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 \
  			lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache \
  			libgl1-mesa-dev libxml2-utils xsltproc unzip \
  			git-core python gnupg flex bison gperf libsdl1.2-dev libesd0-dev \
			squashfs-tools build-essential zip curl libncurses5-dev zlib1g-dev pngcrush \
			schedtool libxml2 libxml2-utils xsltproc lzop libc6-dev schedtool g++-multilib lib32z1-dev lib32ncurses5-dev \
			gcc-multilib liblz4-* pngquant ncurses-dev texinfo gcc gperf patch libtool \
			automake g++ gawk subversion expat libexpat1-dev python-all-dev bc libcloog-isl-dev \
			libcap-dev autoconf libgmp-dev build-essential gcc-multilib g++-multilib pkg-config libmpc-dev libmpfr-dev lzma* \
			liblzma* w3m android-tools-adb maven ncftp htop
}

# Configure ccache for faster incremental/future builds.
# Target directory is in the current user's home directory ~/.ccache
# The ccache cache size is set to 100GB
function setup_ccache()
{
	BASH_CONFIG=$HOME/.bashrc
	echo "Setting up and configuring ccache"
	export USE_CCACHE=1
	export CCACHE_DIR=$HOME/.ccache
	if [ -d prebuilts ]; then
		prebuilts/misc/linux-x86/ccache/ccache -M 100G
		echo "# ccache configuration for Android ROM builds" >> $BASH_CONFIG
		echo "export USE_CCACHE=1" >> $BASH_CONFIG
		. $BASH_CONFIG
	else
		echo "Unable to locate prebuilts/ccache binary. Skipped cache size configuration..."
	fi
}

# Download, configure and install repo into the current user's home directory
function setup_repo()
{
	echo "Setting up repo"
	mkdir $HOME/bin
	export PATH=$HOME/bin:$PATH
	curl https://storage.googleapis.com/git-repo-downloads/repo > $HOME/bin/repo
	chmod a+x $HOME/bin/repo
}

# Prints the dARCrom header and additional information about this script
function make_magic()
{
	echo ""
	echo "██████╗  █████╗ ██████╗  ██████╗██████╗  ██████╗ ███╗   ███╗"
    echo "██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔═══██╗████╗ ████║"
    echo "██║  ██║███████║██████╔╝██║     ██████╔╝██║   ██║██╔████╔██║"
    echo "██║  ██║██╔══██║██╔══██╗██║     ██╔══██╗██║   ██║██║╚██╔╝██║"
    echo "██████╔╝██║  ██║██║  ██║╚██████╗██║  ██║╚██████╔╝██║ ╚═╝ ██║"
    echo "╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝"
    echo ""
    echo "Initial Android ROM build environment setup script!"
    echo ""
    echo "Copyright (c) 2017 - dARCrom || https://github.com/dARCrom"
    echo ""
    echo "Script Author: Patrick Jung <patrick.pddstudio@gmail.com>"
    echo ""
    echo ""
    echo "============================================================"
    echo "=!! WARNING !! WARNING !! WARNING !! WARNING !! WARNING !! ="
    echo "============================================================"
    echo ""
    echo "You are using this script at your own risk!"
    echo "Neither dARCrom nor any of the authors is responsible for"
    echo "any damage that might occur!"
    echo ""
    echo "Check the README for more information."
    echo "You have 10s to abort this script before it starts the"
    echo "configuration process!"
    echo ""
    echo "============================================================"
    echo "=!! WARNING !! WARNING !! WARNING !! WARNING !! WARNING !! ="
    echo "============================================================"
    echo ""

    sleep 10
    
    update_system
    install_java
    
    if [ $? -eq 0 ]; then
    	install_build_dependencies
    else
    	echo "Something went wrong during java 8 installation process."
    	echo "Check the console output and try to fix it manually."
    	echo "Aborting!"
    	return 1
    fi

    if [ $? -eq 0 ]; then
    	#ccache % repo
    	echo "Everything done!"
		exit 0
    else
    	echo "An error occurred while installing build dependencies."
    	echo "Check the console	output and try to fix it manually."
    	echo "Aborting"
    	exit 1
}

# Main entry point
clear
make_magic
