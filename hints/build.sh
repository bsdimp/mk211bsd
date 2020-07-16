#!/bin/sh

# Script to build a 2.11BSD pl 0 system from recoverd sources on a 2.11pl195
# system that we have extant.

R=/scratch
S=$R/usr/src

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

# OK, now it's time to jump into the chroot.
echo Launching the chroot build
cd /
#chroot $R sh -c /build2.sh
