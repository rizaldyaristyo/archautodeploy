# "ArchAutoDeploy" _Arch Linux Auto Install Script_

#### WARNING! Proceed at your own risk!<br>

Tested on a Oracle VirtualBox and VMWARE Workstation <br>
This is a bash script that will auto-**install the arch linux as the only OS and is not intended for dualbooting**<br>
As said the script **will wipe the entire disk** per confirmation prompt, please take a backup before proceeding<br>
No working environment included, I'll work on it soon

## Requirements:

-   Internet Connection
-   ~1GB RAM (Recommended)
-   ~40GB Drive (Recommended, tested on SATA and NVMe)
    -   Because the setup is as follows (feel free to adjust the script to your liking):
        -   Partition 1 = 550M EFI
        -   Partition 2 = 350M BIOS (I know it's too much, future tests are welcome)
        -   Partition 3 = (Whatever you Want in G) Root
        -   Partition 4 = 2GB Swap
-   ~1 Core X86_64 Processor
-   GPT Partition Style Capable System
-   UEFI Capable System is Recommended, BIOS is Okay

## Arch Linux ISO and Recommended Bootable Creator

You need to first download and make a bootable image of arch linux<br>
[Arch Linux Download Page](https://archlinux.org/download/)<br>
Once done, you can make a bootable usb via Balena Etcher<br>
[Balena Etcher Download Page](https://www.balena.io/etcher/)<br>

## Installation (Usage)

Boot to the Arch Install Medium (X86_64 UEFI)
<br>Make sure you're connected to the internet or else this won't work
<br>Once entered the archiso environment, enter these commands

```
pacman -Sy git --noconfirm
git clone https://github.com/rizaldyaristyo/archautodeploy.git
cd archautodeploy
```

then edit the config file **(PLEASE PAY ATTENTION)**

```
nano aad.conf
```

then run the script and wait

```
chmod +xrw *.sh
./aad.sh
```

---

<br>Enjoy your arch<br>
