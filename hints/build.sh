#!/bin/sh

# Script to build a 2.11BSD pl 0 system from recoverd sources on a 2.11pl195
# system that we have extant.

R=/scratch
S=$R/usr/src

#
# Bootstap as to make .s -> .o. That's done in the recovery script due to the
# diffuclty of marshalling all the bits to the 2.11 system. Here we just copy
# the results. We also clean up all the binaries we produced in the hacky way
# so we don't have issues with permissions and/or timestamps later. We'll
# also do a make clean, but this is an abundance of caution move at this staage
# given the turn around time.
#
echo Copying bootstrapped as...
cd $S/bin/as
cp as $R/bin
cp as2 $R/lib
rm -f as as2 *.o

#
# Once we have the .o files, we need to link them into binaries. We also need to
# create libraries. ld(1) is what turns .o files into other .o files as well as
# executables. nm(1) is used by the lorder(1) script to create the long list of
# library dependencies, so it has to grok the old formwat too. We don't build
# ar(1) here, though, because the ar(5) format is the same, even if the ar(1)
# program changed to be the one from 4.3BSD in patch 173.
#
# Finally, we do technically need ranlib(1) if we don't want to do a crapton of
# surgery on the source tree, so remove it and copy /bin/true into it's
# place. This will result in slower link times for the first few binaries we
# build, but the binaries will be the same and ranlib(1) will be one of those
# libraries. Except for libc, which has some circular dependencies, so we have
# to list -lc on the command line below to pull in all those cycles. It won't
# actually link things multiple times, though, since it only gets .o's that
# were missed in the first pass.
#
echo Bootstrapping ld and nm and faking ranlib
cd $S/bin
cc -o ld -O -i -I$S/usr/include ld.c -lc
cc -o nm -O -i -I$S/usr/include nm.c -lc
cp nm ld $R/bin
rm -f ld nm
rm $R/usr/bin/ranlib
cp $R/bin/true $R/usr/bin/ranlib

# OK, now it's time to jump into the chroot.
echo Launching the chroot build
cd /
chroot $R build2.sh
