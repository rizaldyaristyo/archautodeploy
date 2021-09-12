#!/bin/bash
if [ -d /sys/firmware/efi ]; then
    echo OK! - UEFI Confirmed!
else
    echo BAD - UEFI Only! Legacy BIOS not supported.
    echo MESSAGE - If this was a mistake please comment out the ifelse statement in the script and proceed
    exit 1 
fi
if [ -f chroot.sh ]; then
    echo OK! - chroot script present!
else
    echo BAD - chroot script is missing!
    echo MESSAGE - Please re-clone the repo and try again as the file needed in chroot process is missing
    exit 1
sfdisk -l
echo .
echo .
echo WARNING!
echo THIS SCRIPT WILL WIPE YOUR SELECTED DRIVE AND INSTALL ARCH LINUX AS THE ONLY OS
echo KEEP IN MIND THAT THIS SCRIPT IS NOT INTENDED FOR LEGACY BIOS USE AND DUAL BOOTING
echo THIS SCRIPT DISTRIBUTED AS IS AND PLEASE PROCEED AT YOUR OWN RISK.
echo .
read -p "Enter desired arch username: " archUName
echo Your arch username will be $archUName
read -s "Enter a password: " archPasswd
echo Password received
echo .
read -p "Define your drive name (e.g. /dev/sda, /dev/sdb, /dev/nvme0n1): " driveName
sfdisk -l $driveName
echo .
echo "You entered $driveName This will delete all the data in the drive"   
assign1="1"; assign2="2"; assign3="3"
drive1="$driveName$assign1"; drive2="$driveName$assign2"; drive3="$driveName$assign3"
echo "This'll create $drive1, $drive2, and $drive3 afterward"
echo .
read -p "Are you sure? " -n 1 -r
echo .
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo .
    echo .
    echo Working...
    wipefs -a $driveName
    (echo o; echo y; echo w; echo y;) | gdisk $driveName
    (echo n; echo ; echo ; echo +300M; echo t; echo ; echo w) | fdisk $driveName
    (echo n; echo ; echo ; echo +36G; echo t; echo ; echo 20; echo w) | fdisk $driveName
    (echo n; echo ; echo ; echo +2G; echo t; echo ; echo 19; echo w) | fdisk $driveName
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
    echo chroot setup complete!
    echo Rebooting...
    reboot
fi
echo ; echo Exitting...
exit 0
