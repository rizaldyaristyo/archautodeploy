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
        if [ "$ARCHDISK" = "/dev/sr0" ]; then; echo "Try another disk!"
        if [ "$ARCHDISK" = "/dev/loop0" ]; then; echo "Try another disk!"
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if [ -b $ARCHDISK ]; then; break
            else
                echo Disk $ARCHDISK does not exist!
                echo Please select a valid disk!
            fi
        fi
    done

    # BOOT PARTITION
    echo Do You already have a boot partition?
    read -p "(y/N) " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        while true; do
            echo Select the disk you want to install BOOT on:
            read BOOTDISK
            echo You selected $BOOTDISK
            echo Is this correct?
            read -p "(y/N) " -n 1 -r
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [ -b $BOOTDISK ]; then; break
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
        while true; do
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                echo Select the disk you want to install BOOT on:
                read BOOTDISK
                echo You selected $BOOTDISK
                echo Is this correct?
                read -p "(y/N) " -n 1 -r
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    if [ -b $BOOTDISK ]; then; break
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

    echo CONFIRMATION
    echo -------------
    echo Root Partition: $ARCHDISK
    echo Boot Partition: $BOOTDISK
    echo -------------
    echo ;
    echo Is this correct?
    read -p "(y/N) " -n 1 -r
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
    elif [ "$ARCHDISK_DROPT" = "part" ]; then
        echo $ARCHDISK is a PARTITION of a drive!
        echo Are you sure you want to continue?
        echo You will lose all data on $ARCHDISK!
        read -p "(y/N) " -n 1 -r
    fi

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ "$BOOTDISK_DROPT" = "drive" ]; then
            echo $BOOTDISK is a WHOLE drive!
            echo Are you sure you want to continue?
            echo You will lose all data on $BOOTDISK!
            read -p "(y/N) " -n 1 -r
        elif [ "$BOOTDISK_DROPT" = "part" ]; then
            echo $BOOTDISK is a PARTITION of a drive!
            echo Are you sure you want to continue?
            echo You will lose all data on $BOOTDISK!
            read -p "(y/N) " -n 1 -r
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
            if [ -z "$REPLY" ]; then; ARCHDISK_SIZE="20G"
            else; ARCHDISK_SIZE=$REPLY; fi

        if [ "$BOOTDISK" != "$ARCHDISK" ]; then
            BOOTDISK_SIZE=$ARCHDISK_SIZE
            ARCHDISK_DROPT_BOOTDISK="false"
            if [ "$BOOTDISK_DROPT" = "drive" ]; then
                echo How much space do you want to allocate to your BOOT partition?
                echo "If you don't know, just press enter and the default will be used."
                read -p "(Default: 512M) " -r
                if [ -z "$REPLY" ]; then; BOOTDISK_SIZE="512M"
                else; BOOTDISK_SIZE=$REPLY; return 0; fi
            fi
        else
            ARCHDISK_DROPT_BOOTDISK="true"
        fi

        echo CONFIRMATION
        echo -------------
        echo Root Partition: $ARCHDISK_SIZE
        echo Boot Partition: $BOOTDISK_SIZE
        echo -------------
        echo ;
        echo Is this correct?
        read -p "(y/N) " -n 1 -r
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
    if [ "$ARCHDISK_DROPT_BOOTDISK" = "true" ]; then
        if [ "$ARCHDISK" = "drive" ]; then
            wipefs -a $ARCHDISK
            (echo o;echo y;echo w;echo y;) | gdisk $ARCHDISK
            (echo n;echo ;echo ;echo +$BOOTDISK_SIZE;echo y;echo t;echo ;echo 1;echo w) | fdisk $ARCHDISK
            (echo n;echo ;echo ;echo +$ARCHDISK_SIZE;echo y;echo t;echo ;echo 20;echo w) | fdisk $ARCHDISK
            if [ "$ARCHDISK_TYPE" = "scsi" ] then 
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
            elif [ "$ARCHDISK_TYPE" = "nvme" ] then
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
        elif [ "$ARCHDISK" = "part" ]; then
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
        if [ "$ARCHDISK" = "drive" ]; then
            wipefs -a $ARCHDISK
            wipefs -a $BOOTDISK
            (echo o;echo y;echo w;echo y;) | gdisk $ARCHDISK
            (echo o;echo y;echo w;echo y;) | gdisk $BOOTDISK
            (echo n;echo ;echo ;echo +$BOOTDISK_SIZE;echo y;echo t;echo ;echo 1;echo w) | fdisk $BOOTDISK
            (echo n;echo ;echo ;echo +$ARCHDISK_SIZE;echo y;echo t;echo ;echo 20;echo w) | fdisk $ARCHDISK
            if [ "$ARCHDISK_TYPE" = "scsi" ] then 
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
            elif [ "$ARCHDISK_TYPE" = "nvme" ] then
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
        elif [ "$ARCHDISK" = "part" ]; then
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
        echo '#!/bin/bash
        ln -sf /usr/share/zoneinfo/UTC /mnt/etc/localtime
        hwclock --systohc
        pacman -Sy nano --noconfirm
        echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
        locale-gen
        echo LANG=en_US.UTF-8 >> /etc/locale.conf
        echo $ARCH_USERNAME > /etc/hostname
        echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 my.localdomain $ARCH_USERNAME">/etc/hosts
        pacman -Sy netctl dialog dhcpcd wpa_supplicant ifplugd --noconfirm
        useradd -G wheel -m $ARCH_USERNAME
        echo "$ARCH_USERNAME:$ARCH_PASSWORD" | chpasswd
        pacman -Sy grub efibootmgr os-prober --noconfirm
        grub-install --target=x86_64-efi --efi-directory=/efi/ --bootloader-id=arch_grub
        grub-mkconfig -o /boot/grub/grub.cfg
        echo GRUB_DISABLE_OS_PROBER=false >> /etc/default/grub
        echo Please enter a PASSWORD for the ROOT USER before reboot
        passwd
        exit' > chroot.sh
    elif [ "$FIRMWARE_INTERFACE" = "bios" ]; then
        echo '#!/bin/bash
        ln -sf /usr/share/zoneinfo/UTC /mnt/etc/localtime
        hwclock --systohc
        pacman -Sy nano --noconfirm
        echo en_US.UTF-8 UTF-8 >> /mnt/etc/locale.gen
        locale-gen
        echo LANG=en_US.UTF-8 >> /mnt/etc/locale.conf
        echo $ARCH_USERNAME > /mnt/etc/hostname
        echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 my.localdomain $ARCH_USERNAME">/mnt/etc/hosts
        pacman -Sy netctl dialog dhcpcd wpa_supplicant ifplugd --noconfirm
        useradd -G wheel -m $ARCH_USERNAME
        echo "$ARCH_USERNAME:$ARCH_PASSWORD" | chpasswd
        pacman -Sy grub os-prober --noconfirm
        grub-install --target=i386-pc $BOOTDISK
        grub-mkconfig -o /boot/grub/grub.cfg
        echo GRUB_DISABLE_OS_PROBER=false >> /etc/default/grub
        echo Please enter a PASSWORD for the ROOT USER before reboot
        passwd
        exit' > chroot.sh
    fi
    cp chroot.sh /mnt
    chmod +xrw chroot.sh
    export BOOTDISK
    export ARCH_USERNAME
    export ARCH_PASSWORD
    arch-chroot /mnt ./chroot.sh
    rm -f chroot.sh /mnt/chroot.sh
}

if [ -d /sys/firmware/efi ]; then
    echo -e "OKAY - \e[2mBIOS\e[0m \e[7mUEFI\e[0m Confirmed"
    FIRMWARE_INTERFACE="uefi"
    aad_disk_selector
    aad_disk_decider
    aad_disk_sizer
    echo "Continue with UEFI installation? There's no going back now!"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "EXEC - Hold Your Horses!"
        aad_disk_executor
        aad_pacstraper
        clear
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
    echo "Continue with BIOS installation? There's no going back now!"
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "EXEC - Hold Your Horses!"
        aad_disk_executor
        aad_pacstraper
        clear
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