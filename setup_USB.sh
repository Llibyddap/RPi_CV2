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

#exec |& tee /home/pi/setup_logs.txt
exec &> >(tee /home/pi/setup_logs)

clear

printf "\e[42m %-80s \e[m \n" "** Beginning apt-get updates and rsync install"
echo "++++  Update the Raspberry Pi libraries..."
apt-get update
echo "++++  Checking for rsync and installing it if necessary..."
apt-get install rsync -y

echo
printf "\e[42m %-80s \e[m \n" "** Beginning sgdisk flash drive partitioning"

echo "++++  Checking for mounted stuff..."
if grep "sda" /proc/mounts; then
    echo "++++  USB mouinted, attempting to unmount..."
    umount /dev/sda1
    if [ $? -eq 0 ]; then
        echo "++++  Successfully unmounted USB - - continuing..."
    else 
    echo "++++  No mounted USB detected - - continuing..."
    fi
else
    echo "++++  USB isn't mounted - - continuing..."
fi

#echo "++++  Removing GPT and MBR structions - - starting wtih a clean slate..."
#sgdisk -Z /dev/sda          #  destroy GPT and MBR structures
#sgdisk -n 0:0:0 /dev/sda    #  creating new partition for entire usb
#sgdisk -v /dev/sda          #  validating sgdisk
#if [ $? -eq 1 ]; then
#    echo "++++  Critical error partitioning USB drive - - exiting..."
#    exit
#else
#    echo "++++  Disc partitioning completed and validated..."
#fi
#echo "++++  New USB Partition Data..."
#sgdisk -p /dev/sda          #  if successful; providing partition information

#echo "++++  Updating the Raspberry Pi's system files to reflect the new partitions..."
#partprobe /dev/sda1
#if [ $? -eq 1 ]; then
#    echo "++++  Critical error updating kernal with new partitions - - exiting..."
#    exit
#else
#    echo "++++  Kernal updated with new partition tables..."
#fi

wipefs -a /dev/sda

echo 'type=83' | sfdisk /dev/sda

echo
printf "\e[42m %-80s \e[m \n" "** Beginning mke2fs flash drive formatting"
mke2fs -t ext4 -L usbfs /dev/sda1 -F

printf "\e[42m %-80s \e[m \n" "** Mounting flash drive to RaspberryPi @ /mnt"
mount /dev/sda1 /mnt
echo "file system mounted"






echo
printf "\e[42m %-80s \e[m \n" "** Syncing SD filesystem to USB drive"
printf "\e[44m %-40s \e[m \n" "** Details suppressed - - this is a very long process..."
echo
rsync -ax --info=progress2 / /mnt

printf "\e[42m %-80s \e[m \n" "**  Backing up /boot/cmdline.txt"
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

printf "\e[42m %-80s \e[m \n" " "
printf "\e[42m %-80s \e[m \n" "                           ***   DONE   ***"
printf "\e[42m %-80s \e[m \n" " "
