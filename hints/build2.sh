#!/bin/sh

# Note: has to run in 2.11BSDpl195

#
# Build script meant to be kicked off in the chroot to do all the building w/o
# contaminating the 2.11pl195 host. We'll need to use that host *A*LOT* and I'd
# rather not have to reconfigure it all the time.
#
S=/usr/src

#
# These files historically have been owned by root as well
#
chown -R root $S

#
# This is real ugly, but there's a bug in make that has issues with directories
# in the future... so we hack around that by touching all the directories...
# except touch doesn't work on 2.11 on directories, and there's no xargs
# on this system. This is a big hammer, I know, but there's too many date
# issues. The build orchestration scripts will set the date to something
# historically accuate, and this will allow things to work in the face
# of make not descending into a directory that's in the future.
#
for i in `find $S -type d -print` ; do
    touch $i/__fred__ && rm $i/__fred__
done

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
# Build some man pages that aren't otherwise built
# These all have dependencies in their Makefiles...
# still need to work out how best to regenerate all the
# man pages for the release.
(cd bin/chpass; /usr/man/manroff chpass.1 > chpass.0)
(cd bin/passwd; /usr/man/manroff passwd.1 > passwd.0)
(cd etc/chroot; /usr/man/manroff chroot.8 > chroot.0)
(cd etc/fingerd; /usr/man/manroff fingerd.8 > fingerd.0)
(cd etc/ftpd; /usr/man/manroff ftpd.8 > ftpd.0)
(cd etc/mkpasswd; /usr/man/manroff mkpasswd.8 > mkpasswd.0)
(cd etc/vipw; /usr/man/manroff vipw.8 > vipw.0)
(cd ucb/ftp; /usr/man/manroff ftp.1 > ftp.0)
(cd ucb/lock; /usr/man/manroff lock.1 > lock.0)
(cd new/patch; /usr/man/manroff patch.man > patch.0)

# Now we need to clean out /usr/man/cat?/* and rebuild it
# but the normal way of doing that freaks make out (line too
# long). so we use the helper function to do all that. It
# create the man page directly in /usr/man and then greps
# through the Makefiles to create the hard links.
(
    find /usr/man/cat* -name "*.0" -exec rm {} \;
    cd /usr/src/man
    DESTDIR=
    export DESTDIR
    for i in man[1-9]; do
	cd /usr/src/man/$i
	MDIR=`grep MDIR= Makefile | awk '{print $2;}'`
	export MDIR
	for j in *.[1-9]; do
	    c=`echo $j | sed -e 's=\.[1-9]$=.0='`
	    case $j in
		eqn.1)
		    eqn < $j | nroff -man -h > $MDIR/$c
		    ;;
		*)
		    nroff -man -h < $j > $MDIR/$c
		    ;;
	    esac
	done
	grep "ln " Makefile | sh -x
    done
    cd /usr/src
)

# Build it all again now that we've done the above dance
make all
make install
# Install a few artifacts that aren't done by default
(cd games/battlestar ; make stringfile)
(   # because make install doesn't work, we have to copy from the
    # /usr/src/man/Makefile and tewak slightly
    cd man;
    make scriptinstall
#    for file in `find /usr/man -type f -name '*.0' -print`; do \
#	sed -n -f /usr/man/makewhatis.sed $$file; \
#    done | sort -u > whatis.db
#    install -o bin -g bin -m 444 whatis.db /usr/man/whatis
    install -c -o bin -g bin -m 444 man.template /usr/man/man.template
)
# Need to rebuild the find database...
# /usr/lib/find/updatedb
make clean

#
# usr/adm needs some blank files created so logging, etc works.
#
cd /usr/adm
rm -f lpd-errs acct shutdownlog usracct savacct daemonlog debuglog
touch lpd-errs acct shutdownlog usracct savacct daemonlog debuglog

#
# Now build and install the kernel. If all went well, then we're good to go
# here. Set the hostname to the name in the example kernel output from the
# 2.11 setup docs.
#
hostname wlonex.imsd.contel.com
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
(set +e; rm -f ../pdpuba/autoconfig || true)
make clean
make
# (set +e; mv ../pdpuba/autoconfig . || true)
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
