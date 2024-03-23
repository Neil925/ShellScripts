#!/bin/sh

die(){ echo >&2 "$@"; read -n 1 -p Exit?; exit 1; }

while getopts m:u:h:p:vi opt; do
    case "${opt}" in
        m) module=${OPTARG};;
        u) user=${OPTARG};;
        h) hostname=${OPTARG};;
        p) password=${OPTARG};;
        v) vm=y;;
        i) iommu=y;;
        :) die "argument needed to -$OPTARG" ;;
        *) die "invalid switch -$OPTARG" ;;
    esac
done

BASEDIR="/phase2"

PACKAGES=""

while read -r line; do PACKAGES+="${line} "; done < ${BASEDIR}/packages.txt

if [[ $PACKAGES = "" ]]; then
    die "Packes are empty."
fi

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

touch /etc/locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf

touch /etc/hostname
echo $hostname > /etc/hostname

touch /etc/hosts
echo "127.0.0.1         localhost" > /etc/hosts
echo "::1               localhost" >> /etc/hosts
echo "127.0.1.1         ${hostname}.localadmin  ${hostname}" >> /etc/hosts

echo -e "$password\n$password" | (passwd) || die "sudo password failed."

useradd -m $user

echo -e "$password\n$password" | (passwd $user) || die "user password failed."

usermod -aG wheel,audio,video,optical,storage $user

echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf

sed -i 's/#Color/Color/g' /etc/pacman.conf
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf

if [[ $PACKAGES = *linux-ck* ]]; then
    echo -e "\n[repo-ck]\nServer = http://repo-ck.com/\$arch" >> /etc/pacman.conf
    pacman-key -r 5EE46C4C --keyserver keyserver.ubuntu.com && pacman-key --lsign-key 5EE46C4C || die "linux-ck key signing failed"
fi

pacman -Sys reflector --noconfirm || die "Reflector failed to install.";
cp /etc/pacman.d/mirrorlist /etc/pacman.d/backup.mirrorlist;
reflector -p "https,http" > result.txt && cat result.txt > /etc/pacman.d/mirrorlist;

pacman -S sudo nano --noconfirm || die "nano install failed.";

echo -e '%wheel ALL=(ALL:ALL) NOPASSWD: ALL\nDefaults        env_reset,timestamp_timeout=-1' | EDITOR='tee -a' visudo

pacman -S grub efibootmgr dosfstools os-prober mtools --noconfirm || die "Boot manger packages failed."

umount /boot
mkdir /boot/EFI

mount /dev/$module\1 /boot/EFI || die "mount EFI failed."

if [[ $vm = "y" ]]; then
    grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck || die "Grub install failed."
else
    grub-install --target=x86_64-efi --efi-directory=/boot/EFI --removable || die "Grub install failed."
fi

grub-mkconfig -o /boot/grub/grub.cfg || die "Grub config failed."

pacman -S $PACKAGES || die "packages failed."

if [[ $PACKAGES = *sddm* ]]; then
    systemctl enable sddm.service
fi

if [[ $PACKAGES = *networkmanager* ]]; then
    systemctl enable NetworkManager.service
fi

if [[ $PACKAGES = *qemu* ]] && [[ $PACKAGES = *libvirt* ]] && [[ $PACKAGES = *ovmf* ]] && [[ $PACKAGES = *virt-manager* ]]; then
    if [[ $iommu = "y" ]]; then
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&amd_iommu=on /'  /etc/default/grub
        grub-mkconfig -o /boot/grub/grub.cfg
    fi
    systemctl enable libvirtd.service
    systemctl enable virtlogd.socket
    if [[ $PACKAGES = *ebtalbes* ]] && [[ $PACKAGES = *dnsmasq* ]]; then
        virsh net-start default
        virsh net-autostart default
    fi
fi

cp -r $BASEDIR/aur* /home/$user/ || die "Couldn't copy aur installation script to dowlaods.";

echo "================================================================================";
echo "Please install AUR after reboot using the shell script in your home folder.";
echo "================================================================================";

exit 0;