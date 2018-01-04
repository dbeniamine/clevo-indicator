#!/bin/bash

# Copyright (C) 2017  Tetras Libre <Contact@Tetras-Libre.fr>
# Author: Beniamine, David <David.Beniamine@Tetras-Libre.fr>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

if [ `whoami`  != "root" ]
then
    echo "this script should be run as root"
fi

if [ -z "$1" ]
then
    KVER=`uname -r`
else
    KVER=$1
fi
major=`echo $KVER | cut -d '.' -f 1-2`

sudo apt-get install linux-source linux-headers-$KVER
cd /usr/src/
if [ ! -d linux-source-$major ]
then
    tar xvJf linux-source-$major.tar.xz
fi
cd linux-source-$major
make oldconfig
make scripts
cd drivers/acpi
make CONFIG_ACPI_EC_DEBUGFS=m -C /usr/src/linux-headers-$KVER  M=`pwd` modules
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
ln -sf $PWD/ec_sys.ko /lib/modules/$KVER/
depmod
modprobe ec_sys
if [ -z "`grep ec_sys /etc/modules`" ]
then
    echo "adding the module to /etc/modules for automatic load"
    echo "ec_sys" >> /etc/modules
fi
echo "all done, clevo indicator should now work"
