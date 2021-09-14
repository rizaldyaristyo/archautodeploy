#!/bin/bash
# Copyright 2021 kblkLab
# [OPTIONS]
# Variables below can be changed as prefered
# 2nd partition size for root
rootSize = "+36G"
# Additional check skip
checks=true
#

# do not modify what's below unless you know what you're doing
clear
echo '


   ____ ____ ____ 
  ||A |||A |||D ||
  ||__|||__|||__||
  |/__\|/__\|/__\| by kblkLab



'
if [ "$checks" = true ] ; then
    echo Checking...
   if [ -d /sys/firmware/efi ]; then
      echo OK! - UEFI Confirmed!
   else
      echo BAD - UEFI Only! Legacy BIOS not supported.
      echo MESSAGE - If this you think that this was a mistake please modify the script variables manually
      exit 1 
   fi
   if [ -f chroot.sh ]; then
      echo OK! - chroot script present!
   else
      echo BAD - chroot script is missing!
      echo MESSAGE - Please re-clone the repo and try again as the file needed in chroot process is missing
      exit 1
   fi
   if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
      echo OK! - IPv4 is up
   else
      echo BAD - IPv4 is down
      echo MESSAGE - Please connect to the internet via iwctl, if you think that this was a mistake, please modify the script variables manually
      exit 1
   fi
fi
echo ;echo ;
echo ______________________________________WARNING!______________________________________
echo THIS SCRIPT WILL WIPE YOUR SELECTED DRIVE AND INSTALL ARCH LINUX AS THE ONLY OS
echo KEEP IN MIND THAT THIS SCRIPT IS NOT INTENDED FOR LEGACY BIOS USE AND DUAL BOOTING
echo THIS SCRIPT DISTRIBUTED AS IS AND PLEASE PROCEED AT YOUR OWN RISK.
echo ;echo ;
read -p "Enter the desired arch username: " archUName
echo Your arch username will be $archUName
echo ;echo ;
echo -n Provide a password for $archUName: 
read -s archPasswd
echo ;
echo Password received
echo ;echo ;
echo Reading disks list...
lsscsi
echo ;echo ;echo ;
read -p "Define your drive name (e.g. /dev/sda, /dev/sdb, /dev/nvme0n1 without the partition numbering!): " driveName
assign1="1"; assign2="2"; assign3="3"
drive1="$driveName$assign1"; drive2="$driveName$assign2"; drive3="$driveName$assign3"
sfdisk -l $driveName
echo ;echo ;
echo "You entered $driveName This will delete all the data in the drive $driveName"
echo "This'll create $drive1, $drive2, and $drive3 afterward"
echo ;
read -p "Are you sure you want to continue?(y/N) " -n 1 -r
echo ;
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo .
    echo .
    echo Working...
    wipefs -a $driveName
    (echo o; echo y; echo w; echo y;) | gdisk $driveName
    (echo n; echo ; echo ; echo +300M; echo y;  echo t; echo ;  echo 1; echo w) | fdisk $driveName
    (echo n; echo ; echo ; echo $rootSize; echo y;  echo t; echo ; echo 20; echo w) | fdisk $driveName
    (echo n; echo ; echo ; echo +2G; echo y; echo t; echo ; echo 19; echo w) | fdisk $driveName
    mkfs.vfat -F 32 $drive1
    mkfs.ext4 $drive2
    mkswap $drive3
    swapon $drive3
    mount /dev/sda2 /mnt
    mkdir /mnt/efi
    mount /dev/sda1 /mnt/efi
    pacstrap /mnt base linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
    cp chroot.sh /mnt
    chmod +xrw /mnt/chroot.sh
    echo Continuing in chroot...
    export archUName
    export archPasswd
    arch-chroot /mnt ./chroot.sh
    clear
    echo chroot setup complete!
    echo Rebooting...
    reboot
fi
echo ; echo Exitting...
exit 1
