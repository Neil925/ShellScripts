#!/bin/sh

if [ -z $1 ]; then
    echo -n "(L)ocal?/(r)emote: "
    read loc
    if [ -z loc ] || [[ $loc == "" ]]; then
        loc=r
    fi
else
    loc=$1
fi

if [[ $loc == "r" ]] || [[ $loc == "R" ]]; then
    ssh -i '/home/neil/Sensative/.ssh/archlpkey' dhs@72.239.163.236
elif [[ $loc == "l" ]] || [[ $loc == "L" ]]; then
    ssh -i '/home/neil/Sensative/.ssh/archlpkey' dhs@192.168.1.2
else
    echo "Invalid.";
    exit 1;
fi

echo "Connection closed. Press anything to continue."
read -n 1

exit 0
