#!/bin/bash

REPO=${REPO:-./repo}
sync_flags=""

repo_sync() {
	rm -rf .repo/manifest* &&
	$REPO init -u $GITREPO -b $BRANCH -m $1.xml $REPO_INIT_FLAGS
	# && $REPO sync $sync_flags $REPO_SYNC_FLAGS
	ret=$?
	if [ "$GITREPO" = "$GIT_TEMP_REPO" ]; then
		rm -rf $GIT_TEMP_REPO
	fi
	if [ $ret -ne 0 ]; then
		echo Repo sync failed
		exit -1
	fi
}

case `uname` in
"Darwin")
	# Should also work on other BSDs
	CORE_COUNT=`sysctl -n hw.ncpu`
	;;
"Linux")
	CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
	;;
*)
	echo Unsupported platform: `uname`
	exit -1
esac

GITREPO=${GITREPO:-"https://github.com/seinlin/manifests"}
BRANCH=${BRANCH:-emulator-12}

while [ $# -ge 1 ]; do
	case $1 in
	-d|-l|-f|-n|-c|-q|--force-sync|-j*)
		sync_flags="$sync_flags $1"
		if [ $1 = "-j" ]; then
			shift
			sync_flags+=" $1"
		fi
		shift
		;;
	--help|-h)
		# The main case statement will give a usage message.
		break
		;;
	-*)
		echo "$0: unrecognized option $1" >&2
		exit 1
		;;
	*)
		break
		;;
	esac
done

GIT_TEMP_REPO="tmp_manifest_repo"
if [ -n "$2" ]; then
	GITREPO=$GIT_TEMP_REPO
	rm -rf $GITREPO &&
	git init $GITREPO &&
	cp $2 $GITREPO/$1.xml &&
	cd $GITREPO &&
	git add $1.xml &&
	git commit -m "manifest" &&
	git branch -m $BRANCH &&
	cd ..
fi

echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config
echo DEVICE_NAME=$1 >> .tmp-config

case "$1" in
"emulator-10-arm")
	echo PRODUCT_NAME=aosp_arm >> .tmp-config &&
        echo TARGET_NAME=generic >> .tmp-config &&
	repo_sync emulator-10
	;;
"emulator-10-x86_64")
	echo PRODUCT_NAME=aosp_x86_64 >> .tmp-config &&
        echo TARGET_NAME=generic_x86_64 >> .tmp-config &&
	echo BINSUFFIX=64 >> .tmp-config &&
	repo_sync emulator-10
	;;
"emulator-12-arm")
	echo PRODUCT_NAME=aosp_arm >> .tmp-config &&
        echo TARGET_NAME=generic >> .tmp-config &&
	repo_sync emulator-12
	;;
"emulator-12-x86_64")
	echo PRODUCT_NAME=aosp_x86_64 >> .tmp-config &&
        echo TARGET_NAME=generic_x86_64 >> .tmp-config &&
	echo BINSUFFIX=64 >> .tmp-config &&
	repo_sync emulator-12
	;;
"sargo")
	./download_sargo_vendor.sh &&
	echo PRODUCT_NAME=aosp_sargo >> .tmp-config &&
	echo TARGET_NAME=sargo >> .tmp-config &&
	echo BINSUFFIX=64 >> .tmp-config &&
	repo_sync $1
	;;
"onyx")
	echo PRODUCT_NAME=b2g_onyx  >> .tmp-config &&
	echo TARGET_NAME=onyx  >> .tmp-config &&
	repo_sync $1
	;;
"bluejay")
	echo PRODUCT_NAME=aosp_bluejay  >> .tmp-config &&
	echo TARGET_NAME=bluejay  >> .tmp-config &&
	repo_sync $1
	;;
"b2g_gsi")
	repo_sync gsi
	;;	
*)
	echo "Usage: $0 [-cdflnq] [-j <jobs>] [--force-sync] (device name)"
	echo "Flags are passed through to |./repo sync|."
	echo
	echo Valid devices to configure are:
	echo - emulator-10-arm
	echo - emulator-10-x86_64
	echo - emulator-12-arm
	echo - emulator-12-x86_64
	echo - sargo \(Google Pixel 3a\)
	echo - onyx  \(OnePlus X\)
	echo - bluejay \(Google Pixel 6a\)
	echo - b2g_gsi \(B2G Generic System Images\)
	exit -1
	;;
esac

echo GECKO_OBJDIR=$PWD/objdir-gecko-\$PRODUCT_NAME >> .tmp-config

if [ $? -ne 0 ]; then
	echo Configuration failed
	exit -1
fi

mv .tmp-config .config

echo Run \|./build.sh\| to start building
