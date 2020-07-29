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
# cd $S/bin/as
# cp as /bin
# cp as2 /lib
# rm -f as as2 *.o
cd /bs
cp as ld nm /bin
cp as2 /lib

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
# cd ..
# cp nm ld $R/bin 		# see above
# rm -f ld nm
rm $R/usr/bin/ranlib
cp $R/bin/true $R/usr/bin/ranlib

#
# Time to build libc
#
echo Bootstrapping libc
cd $S/lib/libc
make clean
# sometimes this gets skipped, so build it first, unsure why
# but maybe related to recursion and multiple things named
# compat-4.1
(cd pdp/compat-4.1; make)
(cd pdp; make)
make
make install
make clean

[ -r /lib/libc.a ] || (echo no libc.a && exit 1)

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
# Install(1) knows about the format that changed, and so needs to be installed
# before we use 'install -s' or that will fail.
#
echo Bootstrapping install
cd $S/usr.bin
make xinstall
cp xinstall /usr/bin/install

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
(
    cd lib
    for i in ccom cpp c2; do
	(cd $i; make; make install; make clean)
    done
    (
	cd libc
	# Sometimes we fail to descend for reasons as
	# yet unknown -- same name or time of dir? idk
	cd pdp/compat-4.1
	make
	cd ..
	make
	cd ..
	make
	make install
	make clean
    )
    for i in ccom cpp c2; do
	(cd $i; make; make install; make clean)
    done
)
(
    cd usr.lib
    # We need to only build real libraries here and lib.b
    # gets in the way of using the simple lib* here.
    for i in lib[0-9A-Za-z]*; do
	(cd $i; make; make install)
    done
    # usr.lib's install does this, since we're bypassing
    # that, we need to do the link here. Otherwise things
    # fail later.
    rm -f /usr/lib/libm.a /usr/lib/libm_p.a
    ln /usr/lib/libom.a /usr/lib/libm.a
    ln /usr/lib/libom_p.a /usr/lib/libm_p.a
    #
    # Rebuild these now too, while we're here
    #
    for i in lpr me sendmail; do
	(cd $i; make clean; make ; make install)
    done
    make getNAME
    make makekey
)
# Build it all again now that we've done the above dance
make all
make install
make clean

#
# Now build and install the kernel. If all went well, then we're good to go
# here.
#
cd /usr/src/sys/GENERIC
make && make install && (cd / ; cp unix genunix; sh -x /GENALLSYS)

#
# Need to build mdec
#
cd /usr/src/sys/mdec
make clean
make
make install

#
# Ditto autoconfig...
#
cd /usr/src/sys/autoconfig
make clean
make
mv ../pdpuba/autoconfig . || true
make install

#
# Ditto boot
#
cd /usr/src/sys/pdpstand
make clean
make
make install

#
# Hacks for making things bootable
#
# Assume ra device for bootstrap we're ra1 still!
dd if=/mdec/rauboot of=/dev/ra1a count=1
# Try to mount /usr, but it's broken for reasons unknown
# newer 2.11BSD want ra0g, but as released 2.11 wants
# ra0c according to the man page... Need to check the
# actual driver if this doesn't work.
echo /dev/ra0c:/usr:rw:1:2 >> /etc/fstab

# To boot, though, we have to neuter sendmail
mv /usr/lib/sendmail /usr/lib/sendmail.off

# And let's just copy the right kernel to unix
cp /raunix /unix
