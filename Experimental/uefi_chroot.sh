#!/bin/bash
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
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
exit