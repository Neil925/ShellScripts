#!/bin/sh

AUR=/home/$USER/AUR

for d in $AUR/*/ ; do
    cd $d
    rm -r *.tar.zst &> /dev/null
    rm -r *.deb &> /dev/null
    rm -r *.deb.part &> /dev/null
    echo "Checking directory ${d}."
    sleep 1
    if [[ `git pull` = "Already up to date." ]]; then
        continue;
    fi

    PACKAGE=`echo $d | grep -Po "(?<=\/home\/${USER}\/AUR\/)(.*)(?=\/)"`
    figlet $PACKAGE
    sleep 3

    if [[ $PACKAGE = *flutter* ]]; then
        flutter upgrade -f;
    fi
    
    makepkg -sic --noconfirm
done