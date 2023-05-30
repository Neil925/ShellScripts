
PACKAGES=""

BASEDIR=$(dirname $0)

while read -r line; do PACKAGES+="${line} "; done < ${BASEDIR}/packages.txt

echo "The following packages will be installed:"
echo $PACKAGES
echo "Press any key to continue.";

read -n 1

pacman -Sys
pacman -S $PACKAGES

exit 0
