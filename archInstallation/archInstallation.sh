#!/bin/bash

die(){ echo -e >&2 "$@"; exit 1; }
usage(){ echo >&2 "usage: $0 [-m module] [-u username] [-h hostname] [-v] [-i]"; exit 0; }

while getopts m:u:h:vi opt; do
    case "${opt}" in
        m) module=${OPTARG};;
        u) user=${OPTARG};;
        h) hostname=${OPTARG};;
        v) vm=y;;
        i) iommu=y;;
        :) die "argument needed to -$OPTARG" ;;
        *) die "invalid switch -$OPTARG" ;;
    esac
done

if [ -z "$module" ] || [ -z "$user" ] || [ -z "$hostname" ]; then
    die $(usage)
fi

echo -n "Please input a root password: " 
read -s password

echo -ne "\nPlease confirmroot password: " 
read -s cPassword

echo ""

if [ $password != $cPassword ]; then
    die "Password doesn't match! I quit!"
fi

LOCATION=/dev/$module
# 1 is efi_system_partition
EFI=/dev/$module\1
# 2 is swap_partition
SWAP=/dev/$module\2
# 3 is root_partition
ROOT=/dev/$module\3

sed -i 's/#Color/Color/g' /etc/pacman.conf && sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf || die "pacman conf changes failed"

echo location is $LOCATION
echo efi is $EFI
echo swap is $SWAP
echo root is $ROOT

echo "If any of this is wrong, please break the operation. Otherwise, press any key to continue."

read -n 1

BASEDIR=$(dirname $0)

wipefs --all --force $LOCATION
sfdisk $LOCATION < ${BASEDIR}/sda.sfdisk || die "sfdisk failed."

echo "y" | mkfs.fat -F 32 $EFI || die "mkfs.fat failed."
echo "y" | mkswap $SWAP || die "mkswap failed."
echo "y" | mkfs.ext4 $ROOT || die "mkfs.ext4 failed."

swapon $SWAP || die "swapon failed."

mount $ROOT /mnt || die "Mount failed."

pacstrap /mnt base linux linux-firmware || die "pacstrap failed."

genfstab -U /mnt >> /mnt/etc/fstab || die "genfstab failed."

cp -r $BASEDIR/phase2 /mnt || die "Failed to copy phase two into mount.";

arch-chroot /mnt chmod 755 /phase2/*

command="arch-chroot /mnt /phase2/archinstallation2.sh -m $module -u $user -p $password -h $hostname"

if [ $vm ]; then
    command+=" -v" 
fi

if [ $iommu ]; then
    command+=" -i" 
fi

eval $command || die "Second phase fialed to start"

arch-chroot /mnt rm -r /phase2

echo -e "Instllation complete.\nFeel free to reboot when ready."
exit 0
