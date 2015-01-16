# runall step to build CentOS6.5 HVM AMI
#
# $Id$
#

./setup1_partformat.sh
./setup2_preinstall.sh
./setup3_grubconf.sh
./setup4_network.sh
./setup5_final.sh

#
# End Of Script...
#
