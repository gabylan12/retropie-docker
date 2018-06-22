#!/usr/bin/env bash
set -e
buildfolder=/tmp/build-kodi-image
imagefile=target/kodi.img

#MOUNT
#sudo mount -v -o offset=63963136 -t ext4 $imagefile $buildfolder
kpartx -asv $imagefile
dosfslabel /dev/mapper/loop0p1 "KODI"
mount -o rw -t vfat /dev/mapper/loop0p1 $buildfolder/boot
mount -o rw -t ext4 /dev/mapper/loop0p2 $buildfolder/root


#COMMENT FILES
{ echo -n '#'; cat $buildfolder/root/etc/ld.so.preload; } > ld.so.preload.new 
mv -f ld.so.preload.new  $buildfolder/root/etc/ld.so.preload
sed -i -e 's/mmcblk0p/sda/g' $buildfolder/root/etc/fstab

#RUN EMULATE
sudo tunctl -t tap0 && sudo ifconfig tap0 up
sudo tunctl -t tap1 && sudo ifconfig tap1 up
#sudo brctl addif virbr0 tap0
#sudo brctl addif virbr0 tap1

qemu-system-arm -kernel kernel/kernel-qemu-4.4.21-jessie -cpu arm1176 -m 256 -M versatilepb -serial stdio -append "root=/dev/sda2 rootfstype=ext4 rw" -hda $imagefile -net nic,macaddr=00:16:3e:00:00:01 -net tap,ifname=tap0,script=no,downscript=no -redir tcp:5022::22 -no-reboot


