#!/bin/sh

# Copyright 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e

IMG=out/target/product/sargo
PATH=./out/soong/host/linux-x86/bin:$PATH

# Make sure we use an up to date version of fastboot.
# Copied from the factory install 'flash-all.sh' script.
if ! [ $($(which fastboot) --version | grep "version" | cut -c18-23 | sed 's/\.//g' ) -ge 2802 ]; then
  echo "fastboot too old; please download the latest version at https://developer.android.com/studio/releases/platform-tools.html"
  exit 1
fi

adb reboot bootloader

fastboot flash dtbo $IMG/dtbo.img
fastboot flash boot $IMG/boot.img

fastboot reboot fastboot

export ANDROID_PRODUCT_OUT=out/target/product/sargo

fastboot flashall -w

# Required until we sorte out the SELinux mess
adb wait-for-device && adb shell setenforce 0 
