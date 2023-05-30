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

# for sink in ${VALIDSINKS[@]}; do
#     if (( $COUNT < 2 ))
#     then
#         continue
#     fi

#     OUTPUT=$(pulsemixer --id $sink --get-volume)
#     if [[ ! $OUTPUT =  ERR* ]]
#     then
#         VOLUMES=($OUTPUT)
#         if (( ${VOLUMES[0]} > $NUM ))
#         then
#             NUM=${VOLUMES[0]}
#         fi
#     fi
# done

# if (( 1 <= $COUNT ))
# then
#     for sink in ${VALIDSINKS[@]}; do
#         pulsemixer --id $sink --set-volume $NUM
#     done
# fi

for sink in ${VALIDSINKS[@]}; do
    pulsemixer --id $sink --change-volume +5
done