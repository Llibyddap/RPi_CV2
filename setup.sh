#!/bin/bash

#################################################################################
#                                                                               #
#   File:       setup.sh                                                        #
#   Name:       Bill Armstrong                                                  #
#   Date:       November 25, 2019                                               #
#   Plateform:  Raspberry Pi 4; USB Flashdrive                                  #
#   OS:         Raspbian Buster                                                 #
#                                                                               #
#   Desc:       Install Script for OpenCV 4 on USB Flash Drive Mount            #
#                                                                               #
#   Usage:      Script                                                          #
#               i)   partitions, formats and mounts a USB drive to              #
#                    a Raspberry Pi.                                            #
#               ii)  migrates root directory to USB drive.                      #
#               iii) installs OpenCV 4 dependencies                             #
#               iv)  builds OpenCV 4 from source files                          #
#                                                                               #
#   Notes:      This script implements the tutorial instructions provided by    #
#               Adrian Rosebrock @ pyimagesearch.com                            #
#                                                                               #
#               ( https://tinyurl.com/vhue5xl )                                 #
#                                                                               #
#   Install:    Add ssh.txt to boot drive and ssh into the Raspberry Pi.        #
#               From the home directory for pi:                                 #
#                                                                               #
#               pi@raspberrypi $                                                #
#                                                                               #
#################################################################################

clear

printf "\e[42m %-80s \e[m \n" "** Beginning apt-get updates and rsync install"
echo "++++  Update the Raspberry Pi libraries..."
apt-get update
echo "++++  Checking for rsync and installing it if necessary..."
apt-get install rsync -y

printf "\e[42m %-80s \e[m \n" "** Beginning sgdisk flash drive partitioning"

if grep "sda" /proc/mounts; then
    echo "++++  USB mouinted, attempting to unmount..."
    umount /dev/sda1
    if [ $? -eq 0 ]; then
        echo "++++  Successfully unmounted USB - - continuing..."
    else 
    echo "++++  No mounted USB detected - - continuing..."
    fi
else
    choe "++++  USB isn't mounted - - continuing..."
fi

echo "++++  Removing GPT and MBR structions - - starting wtih a clean slate..."
sgdisk -Z /dev/sda          #  destroy GPT and MBR structures
sgdisk -n 0:0:0 /dev/sda    #  creating new partition for entire usb
sgdisk -v /dev/sda
if [ $? -eq 1 ]; then
    echo "++++  Critical error partitioning USB drive - - exiting..."
    exit
else
    echo "++++  Disc partitioning completed and validated..."
fi
echo "++++  New USB Partition Data..."
sgdisk -p /dev/sda

echo "++++  Updating the Raspberry Pi's system files to reflect the new partitions..."
partprobe /dev/sda1

printf "\e[42m %-80s \e[m \n" "** Beginning mke2fs flash drive formatting"
mke2fs -t ext4 -L usbfs /dev/sda1 -F

printf "\e[42m %-80s \e[m \n" "** Mounting flash drive to RaspberryPi @ /mnt"
mount /dev/sda1 /mnt
echo "file system mounted"

printf "\e[42m %-80s \e[m \n" "** Syncing SD filesystem to USB drive"
printf "\e[44m %-40s \e[m \n" "** Details suppressed - - this is a very long process..."
echo
rsync -ax --info=progress2 / /mnt

printf "\e[42m %-80s \e[m \n" "**  Backing up /boot/mdline"
cp /boot/cmdline.txt /boot/cmdline.sd

printf "\e[42m %-80s \e[m \n" "**  Capturing mounted drives and partitions"
echo
blkid
echo
IFS=\" read -r _ vUUID _ vPARTUUID _ < <(blkid /dev/sda1 -s UUID -s PARTUUID)

printf "\e[42m %-80s \e[m \n" "**  Extracted USB drive details:"
printf "\e[44m %-40s \e[m \n" "**  UUID=$vUUID"
printf "\e[44m %-40s \e[m \n" "**  PARTUUID=$vPARTUUID"

printf "\e[42m %-80s \e[m \n" "**  Updating cmdline for USB Partition UUID"
fCMDLINE=/boot/cmdline.txt
fFSTAB=/etc/fstab
printf "\e[44m %-40s \e[m \n" "**  Original File:"
cat $fCMDLINE
sed -i -r -e 's/PARTUUID=([a-z]\S*)/PARTUUID='"$vPARTUUID"'/g' $fCMDLINE
printf "\e[44m %-40s \e[m \n" "**  Updated File:"
cat $fCMDLINE

printf "\e[42m %-80s \e[m \n" "**  Updating FSTAB file for mounts:"
printf "\e[44m %-40s \e[m \n" "**  Original File:"
cat $fFSTAB
sed -i -r -e 's/PARTUUID=([a-z]\S*)/\/dev\/disk\/by-uuid\/'"$vUUID"'/g' $fFSTAB
printf "\e[44m %-40s \e[m \n" "**  Updated File:"
cat $fFSTAB

printf "\e[42m %-80s \e[m \n" "**  Beginning apt-get updates & upgrades"

apt-get dist-upgrade -y
apt-get update
apt-get upgrade -y

printf "\e[42m %-80s \e[m \n" "**  Beginning OpenCV dependencies installation"
printf "\e[44m %-40s \e[m \n" "**  build-essential; cmake; unzip; pkg-config"
apt-get install build-essential cmake unzip pkg-config -y
printf "\e[44m %-40s \e[m \n" "**  libjpeg-dev; libpng-dev; libtiff-dev"
apt-get install libjpeg-dev libpng-dev libtiff-dev -y
printf "\e[44m %-40s \e[m \n" "**  libgtk-3-dev"
apt-get install libgtk-3-dev -y
printf "\e[44m %-40s \e[m \n" "**  libcanberra-gtk* (ARM Specific)"
apt-get install libcanberra-gtk* -y
printf "\e[44m %-40s \e[m \n" "**  libatlas-base-dev; gfortran"
apt-get install libatlas-base-dev gfortran -y
printf "\e[44m %-40s \e[m \n" "**  python3-dev"
apt-get install python3-dev -y
printf "\e[44m %-40s \e[m \n" "**  Clean up...."
apt autoremove -y

printf "\e[42m %-80s \e[m \n" "**  Beginning OpenCV installation"
wget -O opencv.zip https://github.com/opencv/opencv/archive/4.0.0.zip
wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.0.0.zip
unzip opencv.zip
unzip opencv_contrib.zip
mv opencv-4.0.0 opencv
mv opencv_contrib-4.0.0 opencv_contrib
pip install numpy
cd /home/pi/opencv
mkdir build
cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/home/pi/opencv_contrib/modules \
    -D ENABLE_NEON=ON \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF ..

printf "\e[42m %-80s \e[m \n" "**  Adjusting memory swap size to 2048"
fSWAPFILE=/etc/dphys-swapfile
sed -i -r -e 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/g' $fSWAPFILE
echo "dphys-swapfile updated...."
/etc/init.d/dphys-swapfile stop
/etc/init.d/dphys-swapfile start
echo "dphys-swapfile service restarted...."

printf "\e[44m %-40s \e[m \n" "**  Generating Make file with 3 cores (-j3)"
make -j2
printf "\e[44m %-40s \e[m \n" "**  Build OpenCV"
make install
printf "\e[44m %-40s \e[m \n" "**  Generate system link tables"
ldconfig
echo "ldconfig....  Completed...."

printf "\e[42m %-80s \e[m \n" "**  Adjusting memory swap size back to 100"
sed -i -r -e 's/CONF_SWAPSIZE=2048/CONF_SWAPSIZE=100/g' $fSWAPFILE
echo "dphys-swapfile updated...."
/etc/init.d/dphys-swapfile stop
/etc/init.d/dphys-swapfile start
echo "dphys-swapfile service restarted...."

printf "\e[42m %-80s \e[m \n" "**  Renaming files &  creating symlinks"
mv /usr/local/python/cv2/python-3.7/cv2.cpython-37m-arm-linux-gnueabihf.so \
    /usr/local/python/cv2/python-3.7/cv2.so
echo Renaming....   Complete
ln -s /usr/local/python/cv2/python-3.7/cv2.so /usr/lib/python3/dist-packages/cv2.so
echo Creating symlinks....  Complete

printf "\e[42m %-80s \e[m \n" " "
printf "\e[42m %-80s \e[m \n" "                           ***   DONE   ***"
printf "\e[42m %-80s \e[m \n" " "
