# 2.11BSD patch level 0 Recovery Project

According to https://www.krsaborio.net/bsd/research/1991/0314.htm 2.11BSD was
released on March 14, 1991 to celebtrate the 20th anniversary of the PDP-11
computer. It was quickly followed by a series of patches. Sadly, the original
tapes for 2.11BSD have been lost. In the run-up to the 30th anniversary of the
release of 2.11BSD, I wanted to recreate 2.11BSD patch 0, the binary images and
a git repo of all the patches it. 2.11BSD was used as the basis for retrobsd
(https://github.com/RetroBSD/retrobsd) and is currently enjoy a resurgence as
various recreation hardware emulate the PDP-11. The earliest tape is from patch
level 195, and many of these 195 patches destroy information since they were
shell scripts rather than modern patches. The challenge has been to recreate as
much information as possible that's been lost and use that to come up with a
plausable set of original sources, ideally buildable; to recreate the original
tapes, to the degree possible at this late date; and to create a complete github
repo for future generations to study.

## The Challenge

2.11BSD presents a number of challenges to recover the original system. First,
it was a PDP-11 operating system that only ran on the largest PDP-11
systems. Second, it dates from an era where source code control practices were
less robust than today. Third, a number of patches weren't simply files to feed
to patch(1), but rather were instructions of modifications to transition the
system new new patch levels. Forth, sometimes the instructions omitted key steps
that people were evidentially expected to know what to do, but that require
careful research to reconstruct at this late date. Fifth, kernel configs were
inconsistently patched: sometimes the base files to generate the files need to
build the kernel were pathed, other times the generated files were patched
(someitmes in ways that led to conflicts). Finally, a number of small mistakes
were made when the patches were generated, as evidenced by other patches failing
to apply. All these challenges had to be dealt with in order to arrive at a most
likely 2.11BSD system.

### Background on PDP-11

The PDP-11 was introduced in 1970
(https://history-computer.com/ModernComputer/Electronic/PDP-11.html) and started
out life as a minicomputer. It had no MMU and could address 56kB of memory with
an addition 8k for I/O space for devices. Over the years, it was expanded to 18
and then 22 bits with a MMU and later separte I&D space existed to boost the
largest userland address space to 128kB (64kB of instructions and 64kB of
data). It expanded to have a number of different modes apart from Userland and
Kernel. The disks drives expanded from about 5MB for the RK02 that was common on
earlier drives to 3rd party drives late in its life taht could store several
hundred MB.

As such, space was always an issue. By the time 2.11BSD was released, it could
only run on the largest of these machines featuring split I&D space as well as
requiring SUPERVISOR mode support. A large number of overlays were required to
squeeze the kernel into the constrained address space available. This meant that
the system could only run on: PDP-11/44/53/70/73/83/84/93/94 with 22 bit
addressing, a megabyte and floating point.

In 1991 when 2.11BSD was released, it was still encumbered software. Caldera's
freeing of ancient unix was still over a decade away, so the number of origial
tapes made by USENIX was relatively small. An image of the tape was almost
100MB, which was large for the day, so copies weren't saved.

Also, many of the PDP-11s runing 2.11BSD were connected to the internet via
USENET and ultra slow connections. This lead to many tricks to keep the patches
small. This means that patches weren't unified diffs for everything like current
systems. For example, patch 160 includes the instructions:
    0) Be in a temp directory ("cd /tmp" or "cd /usr/tmp")
    1) Save the following shar archive to a file (/tmp/160 for example)
    2) Unpack the archive:  sh 160
    3) Run the script:  ./script
    4) Patch the files:  patch -p0 < patchfile
    5) rm 160 script patchfile
which doesn't sound too bad, but script contains
    #! /bin/sh
    rm -f /usr/src/bin/csh/shortnames.h
    rm -f /usr/src/bin/ar.c
    rm -f /usr/src/bin/ld.c
    rm -f /usr/src/bin/adb/dummy.c /usr/src/bin/adb/mac.h
    rm -f /usr/src/bin/adb/machine.h /usr/src/bin/adb/mode.h
    rm -rf /usr/src/bin/nm rm /usr/src/bin/ld /usr/src/bin/ar
    mkdir /usr/src/bin/nm /usr/src/bin/ld /usr/src/bin/ar
    hmod 755 /usr/src/bin/nm /usr/src/bin/ld /usr/src/bin/ar
    mv /usr/src/bin/nm.c /usr/src/bin/nm/nm.c
    cat > /usr/src/bin/nm/Makefile <<'_MAKEFILE_'
    ...
    chmod 644 /usr/src/bin/nm/Makefile /usr/src/bin/ld/Makefile
which has a stray 'rm,' but more importantly it removes the old copies of all
these files. In modern patches, the unified diff would just remove all the lines
of the file, giving us a record of the old file. This means we have to get
copies of these files somewhere else.

### Source Code Control Practices



### Upgrade by Script

### Missing Instructions

### Inconsistently Patched Kernels

### Errors in the Patches
