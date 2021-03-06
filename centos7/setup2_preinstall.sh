#!/bin/sh
#
#
#

# Target directory
export TDIR=/mnt

cd $TDIR
mkdir $TDIR/etc $TDIR/proc $TDIR/dev

cat > $TDIR/etc/fstab <<EOF
LABEL=/ / ext4 defaults,noatime 1 1
none /dev/pts devpts gid=5,mode=620 0 0
none /dev/shm tmpfs defaults 0 0
none /proc proc defaults 0 0
none /sys sysfs defaults 0 0
EOF

mount -t proc none proc

# yum.conf
cat > $TDIR/repos.conf <<EOF
[ami-base]
name=CentOS-7 - Base
mirrorlist=http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os
gpgcheck=1
gpgkey=file://${TDIR}/RPM-GPG-KEY-CentOS-7

#released updates
[ami-updates]
name=CentOS-7 - Updates
mirrorlist=http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=updates
gpgcheck=1
gpgkey=file://${TDIR}/RPM-GPG-KEY-CentOS-7
EOF

# GPG KEY
wget -O $TDIR/RPM-GPG-KEY-CentOS-7 http://ftp.riken.jp/Linux/centos/RPM-GPG-KEY-CentOS-7

#Install CentOS 7

cd $TDIR
search x86_64 yum -y -c $TDIR/repos.conf --installroot=$TDIR --disablerepo=* --enablerepo=ami-base,ami-updates groupinstall Core
search x86_64 yum -y -c $TDIR/repos.conf --installroot=$TDIR --disablerepo=* --enablerepo=ami-base,ami-updates install kernel 
search x86_64 yum -y -c $TDIR/repos.conf --installroot=$TDIR --disablerepo=* --enablerepo=ami-base,ami-updates install ruby rsync grub
rpm -Uvh --root=$TDIR http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.noarch.rpm
wget -O $TDIR/usr/bin/ec2-metadata http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod +x $TDIR/usr/bin/ec2-metadata

#
# End Of Script...
#


