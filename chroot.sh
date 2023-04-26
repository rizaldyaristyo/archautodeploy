#!/bin/bash
echo arch-chroot environment entered!
ln -sf /usr/share/zoneinfo/UTC # Configure the time zone
hwclock --systohc # Set the hardware clock
pacman -Sy nano --noconfirm # Install nano
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen # Generate locale
locale-gen # Generate locale
echo LANG=en_US.UTF-8 >> /etc/locale.conf # Set the locale
echo $archUName > /etc/hostname # Set the hostname
echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 my.localdomain $archUName">/etc/hosts # Add matching entries to hosts file
pacman -Sy netctl dialog dhcpcd wpa_supplicant ifplugd --noconfirm # Install network manager
useradd -G wheel -m $archUName # Create user
echo "$archUName:$archPasswd" | chpasswd # Set password for user
pacman -Sy grub efibootmgr os-prober --noconfirm # Install grub
grub-install --target=x86_64-efi --efi-directory=/efi/ --bootloader-id=arch_grub # Install grub
grub-mkconfig -o /boot/grub/grub.cfg # Generate grub config
echo GRUB_DISABLE_OS_PROBER=false >> /etc/default/grub # Enable grub os-prober
echo Please enter a password for the root user before reboot
passwd # Set password for root
exit