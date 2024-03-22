#!/bin/sh

cd /home/$user/Downloads;
git clone https://aur.archlinux.org/yay-bin.git;
cd yay-bin;
makepkg -sic --noconfirm;

AURPACKAGES="";

while read -r line; do AURPACKAGES+="${line} "; done < ${BASEDIR}/aurpackages.txt

yay -Sa $AURPACKAGES --noconfirm;

exit 0;