#!/bin/bash

BASE_SEMA_VER="Semaphore_N4_1.5.2j"
VER=""
SEMA_VER=$BASE_SEMA_VER$VER

#export KBUILD_BUILD_VERSION="2"
export LOCALVERSION="-"`echo $SEMA_VER`
#export CROSS_COMPILE=/opt/toolchains/gcc-linaro-arm-linux-gnueabihf-4.8-2013.06_linux/bin/arm-linux-gnueabihf-
export CROSS_COMPILE=/opt/toolchains/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux/bin/arm-linux-gnueabihf-
#export CROSS_COMPILE=/opt/toolchains/gcc-linaro-arm-linux-gnueabihf-4.8-2013.04-20130417_linux/bin/arm-linux-gnueabihf-
#export CROSS_COMPILE=../arm-linux-androideabi-4.7/bin/arm-linux-androideabi-
export ARCH=arm
export SUBARCH=arm
export KBUILD_BUILD_USER=stratosk
export KBUILD_BUILD_HOST="semaphore.gr"

echo 
echo "Making semaphore_mako_defconfig"

DATE_START=$(date +"%s")

#make "mako_defconfig"
make "semaphore_mako_defconfig"

#eval $(grep CONFIG_INITRAMFS_SOURCE .config)
INIT_DIR=../mako_initramfs_4.3
MODULES_DIR=../mako_initramfs_4.3/lib/modules
KERNEL_DIR=`pwd`
OUTPUT_DIR=output/
CWM_DIR=cwm/

echo "LOCALVERSION="$LOCALVERSION
echo "CROSS_COMPILE="$CROSS_COMPILE
echo "ARCH="$ARCH
echo "INIT_DIR="$INIT_DIR
echo "MODULES_DIR="$MODULES_DIR
echo "KERNEL_DIR="$KERNEL_DIR
echo "OUTPUT_DIR="$OUTPUT_DIR
echo "CWM_DIR="$CWM_DIR

#make -j16 modules
make -j16 > /dev/null

rm `echo $MODULES_DIR"/*"`
find $KERNEL_DIR -name '*.ko' -exec cp -v {} $MODULES_DIR \;
cd $INIT_DIR
find . | cpio -o -H newc | gzip -9 > ../initrd.img
cd  $KERNEL_DIR

#make -j16 zImage

#cd arch/arm/boot
#tar cvf `echo $SEMA_VER`.tar zImage
#mv `echo $SEMA_VER`.tar ../../../$OUTPUT_DIR$VARIANT
#echo "Moving to "$OUTPUT_DIR$VARIANT"/"
#cd ../../../

cp arch/arm/boot/zImage ../boot.img
cd ../
./mkbootimg

cp boot.img $CWM_DIR
cd $CWM_DIR
zip -r `echo $SEMA_VER`.zip *
mv  `echo $SEMA_VER`.zip ../$OUTPUT_DIR

DATE_END=$(date +"%s")
echo
DIFF=$(($DATE_END - $DATE_START))
echo "Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
