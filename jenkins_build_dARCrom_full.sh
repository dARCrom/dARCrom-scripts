#!/bin/bash

# A build script written for my jenkins configuration to perform a clean complete dARCrom build.
# !! USE AT OWN RISK !!
#
# /home/pddstudio/dARCrom/out/target/product/bullhead/DU_bullhead_7.1.1_20170316-2209.v11.2-UNOFFICIAL.zip
#
# Authors:
# - Patrick Jung <patrick.pddstudio@gmail.com>
#

#
# variables used by various functions in this build script
#

ROM_DIR_NAME=dARCrom
ROM_SOURCE_DIR=$HOME/$ROM_DIR_NAME

REPO_GIT_URL=https://github.com/dARCrom/android_manifest.git
REPO_GIT_BRANCH=n7x

REPO_BINARY_NAME=repo
REPO_BINARY_PATH=$HOME/bin
REPO_BINARY_DOWNLOAD_URL=https://storage.googleapis.com/git-repo-downloads/$REPO_BINARY_NAME


CCACHE_ENABLED=1
CCACHE_LOCATION=$HOME/.ccache
CCACHE_SIZE=100G
CCACHE_BINARY=$ROM_SOURCE_DIR/prebuilts/misc/linux-x86/ccache/ccache

BUILD_THREADS=-j32

LUNCH_TARGET_NAME=du_bullhead-userdebug

function create_rom_source_directory()
{
	echo "Preparing source root directory..."
	mkdir -p $ROM_SOURCE_DIR
}

function prepare_repo_command()
{
	PATH_TO_REPO=$(which $REPO_BINARY_NAME)
	if [ -x PATH_TO_REPO ]; then
		# exist already
		echo "Found $REPO_BINARY_NAME in PATH!"
	else
		echo "Unable to find $REPO_BINARY_NAME in PATH!"
		
		# Check whether the repo binary is present - and download it if missing
		REPO_LOCATION=$REPO_BINARY_PATH/$REPO_BINARY_NAME
		if [ -f $REPO_LOCATION ]; then
			# Add missing binary directory to PATH
			export PATH=$REPO_BINARY_PATH:$PATH
			echo "Added $REPO_BINARY_NAME to PATH!"
		else
			# Download and configure repo
			echo "$REPO_BINARY_NAME missing... Downloading and configuring it now..."
			mkdir -p $REPO_BINARY_PATH
			export PATH=$REPO_BINARY_PATH:$PATH
			curl $REPO_BINARY_DOWNLOAD_URL > $REPO_LOCATION
			chmod a+x $REPO_LOCATION
		fi
	fi
}

function prepare_ccache()
{
	if [ $CCACHE_ENABLED -eq 0 ]; then
		echo "ccache not enabled. Skipping execution step..."
	else
		echo "Configuring ccache..."
		export USE_CCACHE=$CCACHE_ENABLED
		export CCACHE_DIR=$CCACHE_LOCATION
		if [ -f CCACHE_BINARY ]; then
			$CCACHE_BINARY -M $CCACHE_SIZE
			if [ $? -eq 0 ]; then
				echo "ccache size successfully set to $CCACHE_SIZE"
			else
				echo "Something went wrong during ccache configuration."
				echo "See the console output for more details and try to fix it manually."
			fi
		else
			echo "Unable to find ccache binary. Expected location was: $CCACHE_BINARY"
		fi
	fi
}

function init_or_sync_source()
{
	if [ "$(ls -A $ROM_SOURCE_DIR)" ]; then
		# There is already something in the directory - so we trigger a sync instead of a fresh init
		echo "Target folder is present and not empty. Trying to sync..."
		sync_source
		#TODO: when sync fails - simply purge all and start with a fresh source checkout?
	else
		echo "Initializing source repo..."
		init_source
	fi	
}

function init_source()
{
	cd $ROM_SOURCE_DIR
	repo init -u $REPO_GIT_URL -b $REPO_GIT_BRANCH
}

function sync_source()
{
	cd $ROM_SOURCE_DIR
	repo sync $BUILD_THREADS
}

function clean_clobber_source()
{
	cd $ROM_SOURCE_DIR
	make clean
	make clobber
}

function build_target()
{
	echo "Starting build process..."
	cd $ROM_SOURCE_DIR
	. build/envsetup.sh
	echo "Included build environment setup..."
	lunch $LUNCH_TARGET_NAME
	echo "Configured lunch for $LUNCH_TARGET_NAME"
	make $BUILD_THREADS bacon
	if [ $? -eq 0 ]; then
		echo "Build succeeded!"
		return 0
	else
		echo "Build failed! See console output for details!"
		return 1
	fi
}


# Script entry point
clear
create_rom_source_directory
prepare_repo_command
init_or_sync_source
prepare_ccache
build_target
exit $?