#!/bin/sh

cd /home/$user/Downloads;
git clone https://aur.archlinux.org/yay-bin.git;
cd yay-bin;
makepkg -sic --noconfirm;

PACKAGES="";

while read -r line; do PACKAGES+="${line} "; done < ${BASEDIR}/aurpackages.txt

if [ $PACKAGES = "" ]; then
    echo "Packes are empty.";
    exit 1;
fi

yay -Sa $PACKAGES --noconfirm;

exit 0;