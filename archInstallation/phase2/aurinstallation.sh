#!/bin/sh

cd /home/$(whoami)/Downloads;
git clone https://aur.archlinux.org/yay-bin.git;
cd yay-bin;
makepkg -sic --noconfirm;
cd ../;

sudo sed -i 's/ debug / !debug /g' /etc/makepkg.conf;

PACKAGES="";

while read -r line; do PACKAGES+="${line} "; done < aurpackages.txt

if [[ $PACKAGES = "" ]]; then
    echo "Packes are empty.";
    exit 1;
fi

yay -Sa $PACKAGES --noconfirm;

exit 0;