#!/bin/sh

#
# Build script meant to be kicked off in the chroot to do all the building w/o
# contaminating the 2.11pl195 host. We'll need to use that host *A*LOT* and I'd
# rather not have to reconfigure it all the time.
#

#
# Time to build libc
#
cd $S/lib/libc
make CFLAGS="-O -I$R/usr/include"

# Then what?
# reinstall libc and all the .o's from the csu.
# rebuild as, ld, nm and ranlib and reinstall
# build the whole thing?
# make a new kernel
# profit

