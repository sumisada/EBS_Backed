#!/bin/sh
#
#
#
#

TDIR=/mnt
cd $TDIR

cp -a /dev/xvdf /dev/xvdf1 /mnt/dev/
cp /mnt/usr/*/grub/*/*stage* /mnt/boot/grub/

#
cat > $TDIR/boot/grub/menu.lst <<EOF
default=0
timeout=0
hiddenmenu
title CentOS6.5
        root (hd0,0)
        kernel /boot/vmlinuz-$(rpm --root=$PWD -q --queryformat "%{version}-%{release}.%{arch}\n" kernel) ro root=LABEL=/ console=ttyS0 xen_pv_hvm=enable
        initrd /boot/initramfs-$(rpm --root=$PWD -q --queryformat "%{version}-%{release}.%{arch}\n" kernel).img
EOF

#
chroot /mnt
ln -s /boot/grub/menu.lst /boot/grub/grub.conf
ln -s /boot/grub/grub.conf /etc/grub.conf
exit

#
cat <<EOF | chroot /mnt grub --batch
device (hd0) /dev/xvdf
root (hd0,0)
setup (hd0)
EOF

#
e2label /dev/xvdf1 /
tune2fs -l /dev/xvdf1 | grep name

#
rm -f $TDIR/dev/xvdf $TDIR/dev/xvdf1

#
# End Of Script...
#

