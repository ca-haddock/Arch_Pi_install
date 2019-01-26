#!/bin/sh -exu
dev=$1
cd $(mktemp -d)

function umountboot {
    umount boot || true
    umount root || true
}

# RPi1/Zero (armv6h):
archlinux=/tmp/ArchLinuxARM-rpi-latest.tar.gz
url=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-latest.tar.gz

# RPi2 (armv7h):
# archlinux=/tmp/ArchLinuxARM-rpi-2-latest.tar.gz
# url=http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-2-latest.tar.gz

curl -L -o $archlinux -z $archlinux $url
parted -s $dev mklabel msdos
parted -s $dev mkpart primary fat32 1 128
parted -s $dev mkpart primary ext4 128 -- -1
mkfs.vfat ${dev}1
mkfs.ext4 -F ${dev}2
mkdir -p boot
mount ${dev}1 boot
trap umountboot EXIT
mkdir -p root
mount ${dev}2 root

bsdtar -xpf $archlinux -C root
sync
mv root/boot/* boot

