#!/bin/bash

set -e

rm -rf gsi_dist
mkdir -p gsi_dist/gsi/images
mkdir -p gsi_dist/gsi/bin

source .config

cp out/target/product/$DEVICE_NAME/system.img gsi_dist/gsi/images
cp out/target/product/$DEVICE_NAME/android-info.txt gsi_dist/gsi/images
cp out/soong/host/linux-x86/bin/fastboot gsi_dist/gsi/bin
cp out/soong/host/linux-x86/bin/adb gsi_dist/gsi/bin

cat << EOF > gsi_dist/gsi/flash.sh
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

IMG=./images
PATH=./bin:\$PATH

# Make sure we use an up to date version of fastboot.
# Copied from the factory install 'flash-all.sh' script.
if ! [ \$(\$(which fastboot) --version | grep "version" | cut -c18-23 | sed 's/\.//g' ) -ge 2802 ]; then
  echo "fastboot too old; please download the latest version at https://developer.android.com/studio/releases/platform-tools.html"
  exit 1
fi

adb reboot bootloader

fastboot reboot fastboot

fastboot erase system
fastboot flash system \$IMG/system.img

fastboot -w

fastboot reboot
EOF

chmod +x gsi_dist/gsi/flash.sh

cp out/target/product/$DEVICE_NAME/obj/DATA/sources.xml_intermediates/sources.xml ./gsi_dist/gsi/

cd gsi_dist; tar cf - gsi | xz -v --threads=0 > gsi.tar.xz

echo "==> gsi_dist/gsi.tar.xz is ready!"
