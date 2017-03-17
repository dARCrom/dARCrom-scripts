#!/bin/bash

# A build script written for my jenkins configuration to perform a clean complete dARCrom build.
# !! USE AT OWN RISK !!
#
# Authors:
# - Patrick Jung <patrick.pddstudio@gmail.com>
#

mkdir dARCrom
cd dARCrom

echo "Initializing repo..."
repo init -u https://github.com/dARCrom/android_manifest.git -b n7x
clear

echo "Syncing source, this will take a while..."
repo sync -j32
clear

echo "Sync finished! Beginning build process..."
echo "Loading buildscripts..."
. build/envsetup.sh
lunch #TODO: jenkins need to type <2> here

echo "Everything is up and running! Ready to build..."
echo "Executing make bacon -j32 ..."
make -j32 bacon

echo "Build Done!"
exit 0