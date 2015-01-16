#!/bin/sh 
#
#
#

TDIR=/mnt
cat > $TDIR/etc/sysconfig/network-scripts/ifcfg-eth0 <<EOF
CE=eth0
BOOTPROTO=dhcp
ONBOOT=yes
TYPE=Ethernet
USERCTL=yes
PEERDNS=yes
IPV6INIT=no
EOF

#
sed 's/NETWORKING=no/NETWORKING=yes' $TDIR/etc/sysconfig/network

#
cat > $TDIR/etc/rc.local <<EOF
#!/bin/sh
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

touch /var/lock/subsys/local

# Update the Amazon EC2 AMI creation tools
rpm -Uvh http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools.noarch.rpm

# Update ec2-metadata
wget -O /usr/bin/ec2-metadata http://s3.amazonaws.com/ec2metadata/ec2-metadata
chmod 755 /usr/bin/ec2-metadata

if [ -f "/root/firstrun" ] ; then
dd if=/dev/urandom count=50|md5sum|passwd --stdin root
rm -f /root/firstrun
else
echo "* Firstrun *" && touch /root/firstrun
fi

if [ ! -d /root/.ssh ] ; then
mkdir -p /root/.ssh
chmod 0700 /root/.ssh
fi

ATTEMPTS=5
FAILED=0
# Fetch public key using HTTP
while [ ! -f /root/.ssh/authorized_keys ]; do
curl -f http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key > /tmp/aws-key 2>/dev/null
if [ $? -eq 0 ]; then
cat /tmp/aws-key >> /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys
rm -f /tmp/aws-key
echo "Successfully retrieved AWS public key from instance metadata"
else
FAILED=$(($FAILED + 1))
if [ $FAILED -ge $ATTEMPTS ]; then
echo "Failed to retrieve AWS public key after $FAILED attempts, quitting"
break
fi
echo "Could not retrieve AWS public key (attempt #$FAILED/$ATTEMPTS), retrying in 5 seconds..."
sleep 5
fi
done
EOF

# sshd 
perl -p -i -e 's,^#PermitRootLogin yes,PermitRootLogin without-password,' $TDIR/etc/ssh/sshd_config
perl -p -i -e 's,^#UseDNS yes,UseDNS no,' etc/ssh/sshd_config
perl -p -i -e 's,^PasswordAuthentication yes,PasswordAuthentication no,' $TDIR/etc/ssh/sshd_config

#selinux
perl -p -i -e 's,^SELINUX=enforcing,SELINUX=disabled,' $TDIR/etc/sysconfig/selinux

# disable ipv6
if [ `grep disable_ipv6 /mnt/etc/sysctl.conf | wc -l` -ne 2 ]; then
    cat >> /mnt/etc/sysctl.conf << EOM
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOM
fi

# hide ipv6 hosts
perl -p -i -e 's,::1,#::1,' $TDIR/etc/hosts

#timezone
rm -f $TDIR/etc/localtime
cp -p $TDIR/usr/share/zoneinfo/Japan $TDIR/etc/localtime

#post installation process
setarch x86_64 yum -y -c $TDIR/repos.conf --installroot=$TDIR --disablerepo=* --enablerepo=ami-base,ami-updates clean all

#
# End Of Script...
#

