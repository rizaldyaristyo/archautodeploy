#!/bin/bash
echo arch-chroot environment entered!
ln -sf /usr/share/zoneinfo/UTC # configure time zone
hwclock --systohc # set hardware clock
pacman -Sy nano neofetch --noconfirm # BECAUSE I LOVE NANO and you do want to show off right?
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen # gen locale
locale-gen # gen locale
echo LANG=en_US.UTF-8 >> /etc/locale.conf # set locale

# User and Host Setup
echo ${ARCH_USERNAME}-arch > /etc/hostname # Set the hostname
echo -e "127.0.0.1 localhost\n::1 localhost\n127.0.1.1 my.localdomain ${ARCH_USERNAME}-arch">/etc/hosts # add loopback entries to hosts file
pacman -Sy networkmanager wpa_supplicant --noconfirm # install network managers
useradd -G wheel -m ${ARCH_USERNAME} # create user
echo "${ARCH_USERNAME}:${ARCH_PASSWORD}" | chpasswd # set password

# Install Grub
pacman -Sy grub efibootmgr os-prober --noconfirm # Install grub
grub-install --target=x86_64-efi --efi-directory=/efi/ --bootloader-id=arch_grub # install EFI grub
grub-install --target=i386-pc ${DRIVE_TO_USE_AND_WIPE} # install BIOS grub
grub-mkconfig -o /boot/grub/grub.cfg # Generate grub config
echo GRUB_DISABLE_OS_PROBER=false >> /etc/default/grub # Enable grub os-prober

# Configure network to use after reboot
#!/bin/bash

# Detect the network interface in use
netIfaceInUse=$(ip -o -4 route show to default | awk '{print $5}')

# Check if the interface exists
if [ -d "/sys/class/net/${netIfaceInUse}" ]; then
    echo "Configuring NetworkManager for interface ${netIfaceInUse}..."
    systemctl enable NetworkManager
    systemctl start NetworkManager
    nmcli con add type ethernet ifname ${netIfaceInUse} con-name "${netIfaceInUse}-dhcp" ipv4.method auto
    nmcli con up "${netIfaceInUse}-dhcp"
else
    echo "No active network interface found, Skipping..."
fi

# Set root password
echo ; echo ;
echo "ALL DONE! - Setting root password..."
echo "${ROOT_PASSWORD}" | passwd --stdin root
echo "Exitting arch-chroot..."
exit