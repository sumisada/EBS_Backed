#!/bin/sh
#
#
#

# create partition /dev/xvdf
#
parted /dev/xvdf --script 'mklabel msdos mkpart primary 1M -1s print quit'
partprobe /dev/xvdf
udevadm settle

# format disk with ext4
mkfs.ext4 /dev/xvdf1

# mount
mount /dev/xvdf1 /mnt

#
# End Of Script...
#

