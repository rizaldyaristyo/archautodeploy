![Demo](https://github.com/kblkLab/readmematz/blob/main/archautodeploy.gif)
# "ArchAutoDeploy" _Arch Linux Auto Install Script_
#### WARNING! Proceed at your own risk!<br>
Tested on a virtualbox VM (Might fail on the other device idk..)<br>
This is a bash script that auto-**install the arch linux as the only OS and is not intended for dualbooting**<br>
**it only supports X86_64 GPT UEFI Capable Systems.**<br><br>
As said the script **will wipe the entire disk** per confirmation prompt, please take a backup before proceed<br>
No working environment included, so please install manually afterward as you prefer<br>
We're just tinkering around and accidentaly made this so... the script might not be completed yet or lack something...
## Requirements:
- ≥~512GB RAM
- ≥40GB DRIVE
- ≥1 CORE X86_64 PROCESSOR
- GPT UEFI CAPABLE SYSTEM
##### or just follow the official duh... but seriously you'll need around 40GB of disk (by default) and a GPT UEFI capable system<br><br>
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
git clone https://github.com/kblkLab/archautodeploy.git
cd archautodeploy
chmod +xrw *.sh
./archautodeploy.sh
```
Before doing that you can always first edit the variables value in the script (archautodeploy.sh) by using nano or vim to better suit your preferences
```
cd archautodeploy
nano archautodeploy.sh
```
Like so, you can set the root size, skip the check procedure, etc!

<br><br>
___
<br>Enjoy your arch<br>
