#!/bin/sh

#
# Build script meant to be kicked off in the chroot to do all the building w/o
# contaminating the 2.11pl195 host. We'll need to use that host *A*LOT* and I'd
# rather not have to reconfigure it all the time.
#

S=/usr/src

#
# Time to build libc
#
echo Bootstrapping libc
cd $S/lib/libc
make clean
make
make install
make clean

#
# Now we can build new binaries. We build ranlib now because in the 2.11pl195
# system, has inconsistent include files that lead to two struct nlist being
# defined. Once we have ranlib built, then all the tools we need for the next
# stage of bootstrapping are there.
#
echo Bootstrapping a real ranlib
cd $S/usr.bin
cc -O -i -o ranlib ranlib.c -lc
cp ranlib /usr/bin
rm -f ranlib
ranlib /lib/libc.a

#
# Well, let's go for broke, eh?
#
cd $s
make build
