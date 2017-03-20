#!/bin/bash

if [ `whoami`  != "root" ]
then
    echo "this script should be run as root"
fi

sudo aptitude install linux-source linux-headers-`uname -r`
cd /usr/src/
major=`uname -r | cut -d '.' -f 1-2` 
tar xvJf linux-source-$major.tar.xz
cd linux-source-$major
make oldconfig
make scripts
cd drivers/acpi
make CONFIG_ACPI_EC_DEBUGFS=m -C /usr/src/linux-headers-`uname -r`  M=`pwd` modules
insmod ec_sys.ko
res=$?
if [ $res -ne 0 ]
then
    echo "Failed to insert the module, something might have failed during build"
    exit $res
else
    echo "module correctly built"
fi
rmmod ec_sys
modprobe ec_sys
if [ -z "`grep ec_sys /etc/modules`" ]
then
    echo "adding the module to /etc/modules for automatic load"
    echo "ec_sys" >> /etc/modules
fi
echo "all done, clevo indicator should now work"
