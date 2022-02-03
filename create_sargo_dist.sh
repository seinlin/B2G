#!/bin/bash

set -e

rm -rf sargo_dist
mkdir -p sargo_dist/sargo/images
mkdir -p sargo_dist/sargo/bin

source .config

cp out/target/product/sargo/*.img sargo_dist/sargo/images
cp out/target/product/sargo/android-info.txt sargo_dist/sargo/images
cp out/soong/host/linux-x86/bin/fastboot sargo_dist/sargo/bin
cp out/soong/host/linux-x86/bin/adb sargo_dist/sargo/bin

cat << EOF > sargo_dist/sargo/flash.sh
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

fastboot flash dtbo \$IMG/dtbo.img
fastboot flash boot \$IMG/boot.img

fastboot reboot fastboot

export ANDROID_PRODUCT_OUT=\$IMG

fastboot flashall -w
EOF

chmod +x sargo_dist/sargo/flash.sh

cp out/target/product/$DEVICE_NAME/obj/DATA/sources.xml_intermediates/sources.xml ./sargo_dist/sargo/

cd sargo_dist; tar cf - sargo | xz -v --threads=0 > sargo.tar.xz

echo "==> sargo_dist/sargo.tar.xz is ready!"
