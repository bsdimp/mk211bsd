#!/bin/sh

#
# Build script meant to be kicked off in the chroot to do all the building w/o
# contaminating the 2.11pl195 host. We'll need to use that host *A*LOT* and I'd
# rather not have to reconfigure it all the time.
#

S=/usr/src

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
cp as /bin
cp as2 /lib
rm -f as as2 *.o

#
# Copy over the bootstrapped nm and ld.
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
cp nm ld $R/bin
rm -f ld nm
rm $R/usr/bin/ranlib
cp $R/bin/true $R/usr/bin/ranlib

#
# Time to build libc
#
echo Bootstrapping libc
cd $S/lib/libc
make clean
make all
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
# Now we need to install a few binaries needed for the rest of the build
#
echo Bootrapping ar and strip
cd $S/bin
make ar strip
cp ar strip /bin
rm ar strip

#
# Now we need to bootstrap the kernel config. The undo process leads us to a
# place where /sys is inconsistent. This restores consistency.  Or at least
# generates a better sys/h/localdefs.h for building everything else.
#
cd $S/sys/conf
./config GENERIC

#
# Build and install the C compiler. Rebuild and install
# the C library. Rebuild and reinstall the C compiler.
# (likely overkill).
#
# Then build and install all the libraries in $S/usr.lib,
# but not the programs, they need these same libraries
# so we'll catch them later.
#
# Finally, do a simple make all.
#
# Make build is almost the same as this (gets details
# wrong about usr.lib), but fails in building libc the
# second time for reasons unknown. This sequence should
# be completely reproducible.
#
cd $S
make clean
cd lib
for i in ccom cpp c2 libc ccom cpp c2; do
    (cd $i; make all; make install; make clean)
done
cd ../usr.lib
for i in lib*; do
    (cd $i; make all; make install; make clean)
done
cd ..
make all
make install
make clean

#
# Now build and install the kernel. Oh, wait that's broken still.
# So we won't do that, won't try to build the stand programs nor
# create a tape image (or at least set of TAPE files). That's
# later on the hit parade.
#
