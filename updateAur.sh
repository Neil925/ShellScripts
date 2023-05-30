#!/bin/sh

for d in /home/neil/AUR/*/ ; do
    cd $d
    if [[ `git pull` = "Already up to date." ]]; then 
        continue;
    else
        echo "${d/"/home/neil/AUR/"/""} will now be updated."
        makepkg -s -i -c
    fi
done