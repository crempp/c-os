#!/bin/bash

BUILD_DIR="build"
OUT_DIR="pcjs"
FLP_FILE="c-os.flp"
FLP_FULL_FILE="c-os-full.flp"
DISK_SIZE=163839 # 163840 - 1
DISKDUMP_PATH="/Users/crempp/opt/pcjs/modules/diskdump/bin/diskdump"
JSON_FILE="c-os.json"


rm ./$BUILD_DIR/$FLP_FULL_FILE
cp ./$BUILD_DIR/$FLP_FILE ./$BUILD_DIR/$FLP_FULL_FILE
dd if=/dev/zero of=./$BUILD_DIR/$FLP_FULL_FILE bs=1 count=1 seek=$DISK_SIZE

rm $OUT_DIR/$JSON_FILE
node $DISKDUMP_PATH --debug --disk=./$BUILD_DIR/$FLP_FULL_FILE --format=json --output=$OUT_DIR/$JSON_FILE