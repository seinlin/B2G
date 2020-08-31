#!/bin/bash

# Download the vendor blobs from https://developers.google.com/android/drivers#sargo

FOUND=0

download() {
SHA=$(sha256sum -b $1 |cut -d' ' -f1)
# Check if file exists and is 0 byte or unmatched sha256
if [ -f "$1" -a ! -s "$1" -o "$2" = "$SHA" ]; then
	echo "$1 already downloaded."
	FOUND=$(($FOUND + 1))
else
	wget https://dl.google.com/dl/android/aosp/$1 -O $1
fi
}

download google_devices-sargo-qq3a.200805.001-ca5e20a1.tgz d583419e8b6ae3b7a36fefc3050f0f7cb93ae812c7ca01978976cbd2be43a948
download qcom-sargo-qq3a.200805.001-ebd290fb.tgz d15521998473b76ea5b03bcde1f6f8fa64a5dc0d76c2bd74ab0bece1ef5e21bf

if [ $FOUND != 2 ]
then
  echo "About to extract files."
  # Cleanup vendor/
  rm -rf vendor/
  # Extract the scripts.
  tar xf google_devices-sargo-qq3a.200805.001-ca5e20a1.tgz
  tar xf qcom-sargo-qq3a.200805.001-ebd290fb.tgz
  ./extract-google_devices-sargo.sh
  ./extract-qcom-sargo.sh
  > google_devices-sargo-qq3a.200805.001-ca5e20a1.tgz
  > qcom-sargo-qq3a.200805.001-ebd290fb.tgz
  rm -f extract-google_devices-sargo.sh
  rm -f extract-qcom-sargo.sh
fi

echo "Done."

