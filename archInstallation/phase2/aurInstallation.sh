#!/bin/sh

AUR=/home/$USER/AUR

for d in $AUR/*/ ; do
    cd $d
    makepkg -sic --noconfirm

    if [[ $d = *nord* ]]; then
        systemctl enable nordvpnd
    fi

    if [[ $d = *ckb-next* ]]; then
        systemctl enable ckb-next-daemon
    fi
done

exit 0