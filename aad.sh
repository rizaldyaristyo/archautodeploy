#!/bin/bash

# Copyleft 2021 Aristyo
source aad.conf

clear
echo '
     ____ ____ ____ 
    ||A |||A |||D ||
    ||__|||__|||__||
    |/__\|/__\|/__\|.sh
'
if [ -f aad.conf ]; then
    echo OK! - aad.conf present!
else
    echo BAD - aad.conf is missing!
    echo MSG - Please re-clone the repo and try again
    exit 1
fi
if [ "$CHECKS" = true ]; then
    echo Checking...
    if [ -d /sys/firmware/efi ]; then
		echo OK! - UEFI Confirmed!
    else
		echo BAD - UEFI Only! Legacy BIOS not supported.
		echo MSG - If this you think that this was a mistake please modify the script variables manually
		exit 1 
    fi
    if [ -f chroot.sh ]; then
		  echo OK! - chroot script present!
    else
      echo BAD - chroot script is missing!
      echo MSG - Please re-clone the repo and try again as the file needed in chroot process is missing
		  exit 1
    fi
    if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
		  echo OK! - IPv4 is up
		if ping -q -c 1 -W 1 google.com >/dev/null; then
			echo OK! - DNS is up
		else
			echo BAD - DNS is down
			echo MSG - Please configure your DNS, if you think that this was a mistake, please modify the script variables manually
			exit 1
		fi
    else
      echo BAD - IPv4 is down
      echo MSG - Please connect to the internet via iwctl, if you think that this was a mistake, please modify the script variables manually
      exit 1
    fi
fi
echo; echo;
echo ______________________________________WARNING!______________________________________
echo THIS WILL WIPE YOUR SELECTED DRIVE AND INSTALL ARCH LINUX AS THE ONLY OS
echo THIS SCRIPT DISTRIBUTED AS IS AND PLEASE PROCEED AT YOUR OWN RISK.
echo ____________________________________________________________________________________
echo; echo;
echo Your arch username will be $ARCH_USERNAME
echo; echo;
sfdisk -l ${DRIVE_TO_USE_AND_WIPE}
echo; echo;
echo "You entered ${DRIVE_TO_USE_AND_WIPE}. This will delete all the data in the drive ${DRIVE_TO_USE_AND_WIPE}"
echo "This'll create ${DRIVE_TO_USE_AND_WIPE}1, ${DRIVE_TO_USE_AND_WIPE}2, ${DRIVE_TO_USE_AND_WIPE}3, and ${DRIVE_TO_USE_AND_WIPE}4 afterward"
echo;
read -p "Are you sure you want to continue? (THERE'S NO TURNING BACK!) (y/N): " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]];then
    echo; echo;
    echo Working...
    echo; echo;
    wipefs -a ${DRIVE_TO_USE_AND_WIPE} # drive wipe
    (echo o; echo y; echo w; echo y;) | gdisk ${DRIVE_TO_USE_AND_WIPE} # new GPT table
    
    # Partitioning, tested on fdisk (util-linux 2.40.2)
    (echo n; echo; echo; echo +550M; echo y; echo t; echo ; echo 1; echo w) | fdisk ${DRIVE_TO_USE_AND_WIPE} # BOOT EFI partition
    (echo n; echo; echo; echo +350M; echo y; echo t; echo ; echo 4; echo w) | fdisk ${DRIVE_TO_USE_AND_WIPE} # BOOT BIOS partition
    (echo n; echo; echo; echo "+${ROOT_PARTITION_SIZE}"; echo y; echo t; echo; echo 20; echo w) | fdisk ${DRIVE_TO_USE_AND_WIPE} # root partition
    (echo n; echo; echo; echo +2G; echo y; echo t; echo; echo 19; echo w) | fdisk ${DRIVE_TO_USE_AND_WIPE} # swap partition

    # Formatting
    mkfs.vfat -F 32 ${DRIVE_TO_USE_AND_WIPE}1 # Format EFI partition (Tested on mkfs.fat 4.2)
    (echo "set 2 bios_grub on") | parted ${DRIVE_TO_USE_AND_WIPE} # Format BIOS partition (Tested on GNU Parted 3.6)
    mkfs.ext4 ${DRIVE_TO_USE_AND_WIPE}3 # Format root partition (Tested on mke2fs 1.47.1)
    mkswap ${DRIVE_TO_USE_AND_WIPE}4 # Format swap partition
    swapon ${DRIVE_TO_USE_AND_WIPE}4 # Enable swap partition

    # Mounting
    mount /dev/sda3 /mnt # Mount root partition
    mkdir /mnt/efi # Create EFI mount point
    mount /dev/sda1 /mnt/efi # Mount EFI partition

    pacstrap /mnt base linux linux-firmware # Install base system
    genfstab -U /mnt >> /mnt/etc/fstab # Generate fstab
    cp chroot.sh /mnt # Copy chroot script to /mnt
    chmod +xrw /mnt/chroot.sh # Make chroot script executable
    echo Continuing in chroot...
    export ARCH_USERNAME
    export ARCH_PASSWORD
    export DRIVE_TO_USE_AND_WIPE
    export ROOT_PASSWORD
    arch-chroot /mnt ./chroot.sh # Run chroot script
    clear
    echo chroot setup complete!
    echo Rebooting...
    reboot
fi
echo; echo Exitting...
exit 1
