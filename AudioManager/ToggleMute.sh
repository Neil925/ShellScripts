#!/bin/bash

BASEDIR=$(dirname $0)
PULSELIST=$(pulsemixer --list-sinks | grep sink-input)
NUM=0
VALIDSINKS=()

while read -r line
do
    while read -r list
    do
        if [[ $list = *${line}* ]]
        then
            VALIDSINKS+=($(echo $list | grep -Po "(?<=ID: )(.*)(?=, Name)"))
        fi
    done <<< $PULSELIST
done < ${BASEDIR}/AudioSinks.txt

COUNT=${#VALIDSINKS[@]}
if (( $COUNT == 0 ))
then
    echo "No valid sinks found."
    exit 1
fi

for sink in ${VALIDSINKS[@]}; do
    pulsemixer --id $sink --toggle-mute
done