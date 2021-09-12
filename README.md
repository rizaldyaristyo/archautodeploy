# "ArchAutoDeploy" _Arch Auto Install Script_
#### WARNING! Proceed at your own risk!<br>
Tested on a virtualbox VM (Might fail on the other device idk..)<br>
This is a bash script that auto-**install the arch linux as the only OS**<br>**and is not intended for dualbooting** also it only supports X86_64 GPT UEFI.
As said the script **will wipe the entire disk** per confirmation prompt, please take a backup before proceed
We're just tinkering around and accidentaly made this so... the script might not be completed yet or lack something...
## Recommended Minimum Requirements:
- 1GB RAM
- 40GB DRIVE
- 1-2 CORE PROCESSOR
<br><br>or just follow the official duh... but seriously you'll need around 40GB of disk<br><br>
## Arch Linux ISO and Recommended Bootable Creator
You need to first download and make a bootable image of arch linux<br>
[Arch Linux Download Page](https://archlinux.org/download/)<br>
once done you can make a bootable usb via Balena Etcher<br>
[Balena Etcher Download Page](https://www.balena.io/etcher/)<br>
## Usage:
Boot to the Arch Install Medium (X86_64 UEFI)
<br>Make sure you're connected to the internet or else this won't work
<br>Once entered the archiso environment, enter these commands
```
pacman -Sy git --noconfirm
git clone https://github.com/kblkLab/archautodeploy.git
cd archautodeploy
chmod +xrw *.sh
./archautodeploy.sh
```
<br>Enjoy your arch<br><br><br><br><br><br><br><br>
___
Working environment is not included
