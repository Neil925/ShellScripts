#!/bin/sh

var=$(nordvpn status)

if [[ $var =~ "Disconnected" ]]; then
    ssh -i '/home/neil/Sensative/.ssh/archpckey' dhs@192.168.1.219
else
    ssh -i '/home/neil/Sensative/.ssh/archpckey' dhs@72.239.188.77
fi

exit 0
