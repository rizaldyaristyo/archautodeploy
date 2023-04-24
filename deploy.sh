#!/bin/bash
aad_disk_selector(){
    echo Listing Disks...
    echo ----------------
    lsblk -rino NAME | awk '{print "/dev/"$1}' | grep -Ev 'sr0|loop0'
    echo ----------------
    echo ;
    # ROOT PARTITION
    while true; do
        echo Select the disk you want to install ROOT on:
        read ARCHDISK
        echo You selected $ARCHDISK
        echo Is this correct?
        read -p "(y/N) " -n 1 -r
        echo ;
        if [ "$ARCHDISK" = "/dev/sr0" ]; then
            echo "Try another disk!"
        elif [ "$ARCHDISK" = "/dev/loop0" ]; then
            echo "Try another disk!"
        fi
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [ -b $ARCHDISK ]; then
                break
            else
                echo Disk $ARCHDISK does not exist!
                echo Please select a valid disk!
            fi
        fi
    done

    # BOOT PARTITION
    echo Do You already have a boot partition?
    read -p "(y/N) " -n 1 -r
    echo ;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        while true; do
            echo Select the disk you want to install BOOT on:
            read BOOTDISK
            echo You selected $BOOTDISK
            echo Is this correct?
            read -p "(y/N) " -n 1 -r
            echo ;
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [ -b $BOOTDISK ]; then
                    break
                else
                    echo Disk $BOOTDISK does not exist!
                    echo Please select a valid disk!
                fi
            fi
        done
    else
        echo Do you want to create a boot partition?
        echo "If you select no, your boot partition will be the same as your root partition."
        read -p "(y/N) " -n 1 -r
        echo ;
        while true; do
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo Select the disk you want to install BOOT on:
                read BOOTDISK
                echo You selected $BOOTDISK
                echo Is this correct?
                read -p "(y/N) " -n 1 -r
                echo ;
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if [ -b $BOOTDISK ]; then
                        break
                    else
                        echo Disk $BOOTDISK does not exist!
                        echo Please select a valid disk!
                    fi
                fi
            else
                echo Boot partition will be the same as root partition...
                BOOTDISK=$ARCHDISK
            fi
        done
    fi

    if [ "$BOOTDISK" != "$ARCHDISK" ]; then
        ARCHDISK_IS_BOOTDISK="false"
    else
        ARCHDISK_IS_BOOTDISK="true"
    fi

    echo CONFIRMATION
    echo -------------
    echo Root Partition: $ARCHDISK
    echo Boot Partition: $BOOTDISK
    echo -------------
    echo ;
    echo Is this correct?
    read -p "(y/N) " -n 1 -r
    echo ;
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo OKAY - Initiating Next Step...
        return 0
    else
        echo "EXIT - Have a Nice Day (Canceled)"
        exit
    fi
}

aad_disk_decider(){
    # ROOT PARTITION = $ARCHDISK
    # BOOT PARTITION = $BOOTDISK

    if [[ "$ARCHDISK" =~ ^/dev/nvme[0-9]n[0-9]+$ ]]; then
        ARCHDISK_DROPT="drive"
        ARCHDISK_TYPE="nvme"
    elif [[ "$ARCHDISK" =~ ^/dev/nvme[0-9]n[0-9]+p[0-9]+$ ]]; then
        ARCHDISK_DROPT="part"
        ARCHDISK_TYPE="nvme"
    elif [[ "$ARCHDISK" =~ ^/dev/sd[a-z]*$ ]]; then
        ARCHDISK_DROPT="drive"
        ARCHDISK_TYPE="scsi"
    elif [[ "$ARCHDISK" =~ ^/dev/sd[a-z][0-9]*$ ]]; then
        ARCHDISK_DROPT="part"
        ARCHDISK_TYPE="scsi"
    fi

    if [[ "$BOOTDISK" =~ ^/dev/nvme[0-9]n[0-9]+$ ]]; then
        BOOTDISK_DROPT="drive"
        BOOTDISK_TYPE="nvme"
    elif [[ "$BOOTDISK" =~ ^/dev/nvme[0-9]n[0-9]+p[0-9]+$ ]]; then
        BOOTDISK_DROPT="part"
        BOOTDISK_TYPE="nvme"
    elif [[ "$BOOTDISK" =~ ^/dev/sd[a-z]*$ ]]; then
        BOOTDISK_DROPT="drive"
        BOOTDISK_TYPE="scsi"
    elif [[ "$BOOTDISK" =~ ^/dev/sd[a-z][0-9]*$ ]]; then
        BOOTDISK_DROPT="part"
        BOOTDISK_TYPE="scsi"
    fi

    if [ "$ARCHDISK_DROPT" = "drive" ]; then
        echo $ARCHDISK is a WHOLE drive!
        echo Are you sure you want to continue?
        echo You will lose all data on $ARCHDISK!
        read -p "(y/N) " -n 1 -r
        echo ;
    elif [ "$ARCHDISK_DROPT" = "part" ]; then
        echo $ARCHDISK is a PARTITION of a drive!
        echo Are you sure you want to continue?
        echo You will lose all data on $ARCHDISK!
        read -p "(y/N) " -n 1 -r
        echo ;
    fi

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ "$BOOTDISK_DROPT" = "drive" ]; then
            echo $BOOTDISK is a WHOLE drive!
            echo Are you sure you want to continue?
            echo You will lose all data on $BOOTDISK!
            read -p "(y/N) " -n 1 -r
            echo ;
        elif [ "$BOOTDISK_DROPT" = "part" ]; then
            echo $BOOTDISK is a PARTITION of a drive!
            echo Are you sure you want to continue?
            echo You will lose all data on $BOOTDISK!
            read -p "(y/N) " -n 1 -r
            echo ;
        fi
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo OKAY - Initiating Next Step...
            return 0
        else
            echo "EXIT - Have a Nice Day (Canceled)"
            exit
        fi
    else
        echo "EXIT - Have a Nice Day (Canceled)"
        exit
    fi
}

aad_disk_sizer(){
    while true; do
        if [ "$BOOTDISK_DROPT" = "drive" ]; then
            echo How much space do you want to allocate to your ROOT partition?
            echo "If you don't know, just press enter and the default will be used."
            read -p "(Default: 20G) " -r
            if [ -z "$REPLY" ]; then
                ARCHDISK_SIZE="20G"
            else
                ARCHDISK_SIZE=$REPLY
            fi
            echo How much space do you want to allocate to your BOOT partition?
            echo "If you don't know, just press enter and the default will be used."
            read -p "(Default: 512M) " -r
            if [ -z "$REPLY" ]; then
                BOOTDISK_SIZE="512M"
            else
                BOOTDISK_SIZE=$REPLY; return 0
            fi
        fi

        echo CONFIRMATION
        echo -------------
        echo Root Partition: $ARCHDISK_SIZE
        echo Boot Partition: $BOOTDISK_SIZE
        echo -------------
        echo ;
        echo Is this correct?
        read -p "(y/N) " -n 1 -r
        echo ;
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo OKAY - Initiating Next Step...
            return 0
        else
            echo Revision It Is!
        fi
    done
}

aad_credential_manager(){
    while true; do
        echo Enter Your Username:
        read ARCH_USERNAME
        echo Enter Your Password:
        read -s ARCH_PASSWORD
        echo Enter Your Password Again:
        read -s ARCH_PASSWORD2
        if [ "$ARCH_PASSWORD" = "$ARCH_PASSWORD2" ]; then
            echo OKAY - Initiating Next Step...
            return 0
        else
            echo Passwords do not match!
            echo Please try again!
        fi
    done
}

aad_disk_executor(){
    if [ "$ARCHDISK_IS_BOOTDISK" = "true" ]; then
        if [ "$ARCHDISK_DROPT" = "drive" ]; then
            wipefs -a $ARCHDISK
            if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                echo -e "o\nn\np\n1\n\n\nw\n" | fdisk -c=dos $ARCHDISK
            elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                (echo o;echo y;echo w;echo y;) | gdisk $ARCHDISK
            fi
            (echo n;echo ;echo ;echo +$BOOTDISK_SIZE;echo y;echo t;echo ;echo 1;echo w) | fdisk $ARCHDISK
            (echo n;echo ;echo ;echo +$ARCHDISK_SIZE;echo y;echo t;echo ;echo 20;echo w) | fdisk $ARCHDISK
            if [ "$ARCHDISK_TYPE" = "scsi" ]; then 
                mkfs.fat -F 32 $ARCHDISK"1"
                mkfs.ext4 $ARCHDISK"2"
                mount $ARCHDISK"2" /mnt
                if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                    mkdir /mnt/boot
                    mount $ARCHDISK"1" /mnt/boot
                elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                    mkdir /mnt/efi
                    mount $ARCHDISK"1" /mnt/efi
                fi
                return 0
            elif [ "$ARCHDISK_TYPE" = "nvme" ]; then
                mkfs.fat -F 32 $ARCHDISK"p1"
                mkfs.ext4 $ARCHDISK"p2"
                mount $ARCHDISK"p2" /mnt
                if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                    mkdir /mnt/boot
                    mount $ARCHDISK"p1" /mnt/boot
                elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                    mkdir /mnt/efi
                    mount $ARCHDISK"p1" /mnt/efi
                fi
            fi
            return 0
        elif [ "$ARCHDISK_DROPT" = "part" ]; then
            wipefs -a $ARCHDISK
            mkfs.fat -F 32 $ARCHDISK
            mkfs.ext4 $ARCHDISK
            mount $ARCHDISK /mnt
            if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                mkdir /mnt/boot
                mount $ARCHDISK /mnt/boot
            elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                mkdir /mnt/efi
                mount $ARCHDISK /mnt/efi
            fi
            return 0
        fi
    else
        if [ "$ARCHDISK_DROPT" = "drive" ]; then
            wipefs -a $ARCHDISK
            wipefs -a $BOOTDISK
            if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                echo -e "o\nn\np\n1\n\n\nw\n" | fdisk -c=dos $ARCHDISK
                echo -e "o\nn\np\n1\n\n\nw\n" | fdisk -c=dos $BOOTDISK
            elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                (echo o;echo y;echo w;echo y;) | gdisk $ARCHDISK
                (echo o;echo y;echo w;echo y;) | gdisk $BOOTDISK
            fi
            (echo n;echo ;echo ;echo +$BOOTDISK_SIZE;echo y;echo t;echo ;echo 1;echo w) | fdisk $BOOTDISK
            (echo n;echo ;echo ;echo +$ARCHDISK_SIZE;echo y;echo t;echo ;echo 20;echo w) | fdisk $ARCHDISK
            if [ "$ARCHDISK_TYPE" = "scsi" ]; then 
                mkfs.fat -F 32 $BOOTDISK"1"
                mkfs.ext4 $ARCHDISK"2"
                mount $ARCHDISK"2" /mnt
                if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                    mkdir /mnt/boot
                    mount $BOOTDISK"1" /mnt/boot
                elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                    mkdir /mnt/efi
                    mount $BOOTDISK"1" /mnt/efi
                fi
                return 0
            elif [ "$ARCHDISK_TYPE" = "nvme" ]; then
                mkfs.fat -F 32 $BOOTDISK"p1"
                mkfs.ext4 $ARCHDISK"p2"
                mount $ARCHDISK"p2" /mnt
                if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                    mkdir /mnt/boot
                    mount $BOOTDISK"p1" /mnt/boot
                elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                    mkdir /mnt/efi
                    mount $BOOTDISK"p1" /mnt/efi
                fi
                return 0
            fi
        elif [ "$ARCHDISK_DROPT" = "part" ]; then
            wipefs -a $ARCHDISK
            mkfs.ext4 $ARCHDISK
            mount $ARCHDISK /mnt
            if [ "$FIRMWARE_INTERFACE" = "bios" ]; then
                mkdir /mnt/boot
                mount $BOOTDISK /mnt/boot
            elif [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
                mkdir /mnt/efi
                mount $BOOTDISK /mnt/efi
            fi
            return 0
        fi
    fi
}

aad_pacstraper(){
    pacstrap /mnt base linux linux-firmware
    genfstab -U /mnt >> /mnt/etc/fstab
    if [ "$FIRMWARE_INTERFACE" = "uefi" ]; then
        chmod +xrw uefi_chroot.sh
        cp uefi_chroot.sh /mnt/chroot.sh
    elif [ "$FIRMWARE_INTERFACE" = "bios" ]; then
        chmod +xrw bios_chroot.sh
        cp bios_chroot.sh /mnt/chroot.sh
    fi
    if [ "$ARCHDISK_DROPT" = "part" ]; then
        if [ "$ARCHDISK_TYPE" = "nvme" ]; then
            BOOTDISK=${BOOTDISK%??}
        elif [ "$ARCHDISK_TYPE" = "scsi" ]; then
            BOOTDISK=${BOOTDISK%?}
        fi
    fi
    export BOOTDISK
    export ARCH_USERNAME
    export ARCH_PASSWORD
    # arch-chroot /mnt /bin/bash -c "source /chroot.sh"
    arch-chroot /mnt ./chroot.sh
    rm -f chroot.sh /mnt/chroot.sh
}

if [ -d /sys/firmware/efi ]; then
    echo -e "OKAY - \e[2mBIOS\e[0m \e[7mUEFI\e[0m Confirmed"
    FIRMWARE_INTERFACE="uefi"
    aad_disk_selector
    aad_disk_decider
    aad_disk_sizer
    aad_credential_manager
    echo "Continue with UEFI installation? There's no going back now!"
    read -p "Are you sure? [y/N] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "EXEC - Hold Your Horses!"
        aad_disk_executor
        aad_pacstraper
        echo "Installation Complete!"
        echo "Please reboot your system and remove the installation media."
        echo "Then, log in as the user you created and enjoy your new Arch Linux installation!"
        echo "Have a Nice Day!"
        echo "P.S. - If You don't know how to reboot, just type 'reboot' in the terminal and press enter."
        exit
    else
        echo "EXIT - Have a Nice Day (Canceled)"
        exit
    fi
else
    echo -e "OKAY - \e[7mBIOS\e[0m \e[2mUEFI\e[0m Confirmed"
    FIRMWARE_INTERFACE="bios"
    aad_disk_selector
    aad_disk_decider
    aad_disk_sizer
    aad_credential_manager
    echo "Continue with BIOS installation? There's no going back now!"
    read -p "Are you sure? [y/N] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "EXEC - Hold Your Horses!"
        aad_disk_executor
        aad_pacstraper
        echo "Installation Complete!"
        echo "Please reboot your system and remove the installation media."
        echo "Then, log in as the user you created and enjoy your new Arch Linux installation!"
        echo "Have a Nice Day!"
        echo "P.S. - If You don't know how to reboot, just type 'reboot' in the terminal and press enter."
        exit
    else
        echo "EXIT - Have a Nice Day (Canceled)"
        exit
    fi
fi