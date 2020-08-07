#!/bin/sh

# Script to build a 2.11BSD pl 0 system from recoverd sources on a 2.11pl195
# system that we have extant.

R=/ur
S=$R/usr/src

# The build requires /dev/null to work, so create it. While we're here, go head
# and create all the devices we'll need.
echo Creating devices
cd $R/dev
sh ./MAKEDEV std hk0 hk1 ra0 ra1 ra2 ra3 mt0 mt1 nmt0 nmt1 xp0 xp1 rl0 rl1 pty0 dz0 lp0 local

#
# Once we have the .o files, we need to link them into binaries. We also need to
# create libraries. ld(1) is what turns .o files into other .o files as well as
# executables. nm(1) is used by the lorder(1) script to create the long list of
# library dependencies, so it has to grok the old formwat too. We don't build
# ar(1) here, though, because the ar(5) format is the same, even if the ar(1)
# program changed to be the one from 4.3BSD in patch 173.
#
echo Bootstrapping ld and nm and faking ranlib
cd $S/bin
cc -o ld -O -i -I$R/usr/include ld.c -lc
cc -o nm -O -i -I$R/usr/include nm.c -lc
mkdir -p $R/bs
cp ld nm as/as as/as2 $R/bs

# OK, now it's time to jump into the chroot.
echo Launching the chroot build
cd /
#chroot $R sh -c /usr/urbsd/build2.sh
