# ur2.11BSD Testing

This tries to document the tests that I'm using to validate my
reconstruction. There's four major categories of testing. First is backwards
patch consistency. Is the reconstruction consistent with the patches going
backwards? Next is compile consistency: can the resulting system be built and
boot. Next is date consistency. Are the dates that the files wind up with
consistent with a product released in February or March 1991? Finally, there's
forward patch consistency. Can I start at the reconstructed sources and end with
patch 80? Patch 195? Does the catch-up kit work?

## Current status

All but two of the backward patch inconsistencies have been coorected. There's a
change to ctags.c indicated by one. There's also a change to sh (mac.h) which
may indicate a hidden change. All of the rest of the issues have been explained,
or of no consequence.

There's one issue with nslookup that needs to be resolve on the build
consistency test. It's unclear if that needs to be resolved in favor of doing it
by hand, or if the binaries were just missing. I suspect this will be resolved
by hand since the binaries are quite popular.

There's about 20 files that are not date consistent that need looking into. More
details coming. The system is rebuilt in 1991 to help detect these issues. The
current testing methodology loses the dates from patch files, so we are not yet
able to detect missing patches to files that were patched after pl80 (we can
detect it to 80 since the catch-up kit has a complete set of patches).

There's still a few inconsistencies with patching to pl80 with the catch-up
kit. Those need to be documented. Mostly files that are expected to be present
by the upgrade scripts, but are not. It's unclear if some of the removals were a
just in case thing, or the files really were on the master tape. The bulk of the
remaining ones deal with local machine configuration. No attempt has been made
to walk the patches forward, nor deal with the multitude of added files in patch
80 that are no-where-else documented. No attempt has been made to go from patch
80 -> 195, or try to get close to patch 80 one patch at a time.

It's likely time to create github issues for the first two categories so they
aren't forgotten. The date and catch-up issues need to be burned down a bit more
and documented when the going gets slow there. Much code needs to be written to
do the patch-at-a-time upgrade.

# Backwards Patch Consistency

The very first test is 'is the reconstruction consistent with the patches'. This means, does anything in the patches contradict what has been reconstructed. Examples of this are the patches not apply, applying with unexplained fuzz or line number deltas.

Now that all the patches apply w/o error, I've narrowed the scope of this test. The test is to grep for the words offset or fuzz in the log files:

        % egrep 'Hunk.*offset|fuzz' log/*
        log/107.log:Hunk #1 succeeded at 53 with fuzz 1 (offset -6 lines).
        log/124.log:Hunk #1 succeeded at 69 with fuzz 1 (offset 2 lines).
        log/124.log:Hunk #1 succeeded at 55 (offset 1 line).
        log/142.log:Hunk #1 succeeded at 50 with fuzz 2 (offset 8 lines).
        log/142.log:Hunk #1 succeeded at 50 with fuzz 2 (offset 8 lines).
        log/152.log:Hunk #1 succeeded at 265 (offset 1 line).
        log/152.log:Hunk #2 succeeded at 313 (offset 1 line).
        log/152.log:Hunk #3 succeeded at 354 (offset 1 line).
        log/152.log:Hunk #1 succeeded at 230 (offset 1 line).
        log/152.log:Hunk #2 succeeded at 265 (offset 1 line).
        log/152.log:Hunk #3 succeeded at 284 (offset 1 line).
        log/159.log:Hunk #1 succeeded at 109 with fuzz 2 (offset 27 lines).
        log/159.log:Hunk #1 succeeded at 109 with fuzz 2 (offset 27 lines).
        log/179.log:Hunk #14 succeeded at 1018 with fuzz 1 (offset -8 lines).
        log/42.log:Hunk #1 succeeded at 336 (offset -1 lines).
        log/42.log:Hunk #1 succeeded at 177 (offset -155 lines).
        log/84.log:Hunk #1 succeeded at 325 (offset -1 lines).
        log/84.log:Hunk #2 succeeded at 377 (offset -1 lines).
        log/84.log:Hunk #1 succeeded at 215 (offset -156 lines).
        log/89.log:Hunk #2 succeeded at 403 with fuzz 1 (offset -3 lines).

This indicates that there's 20 issues that need explaining in some way. Based on the current text below, there's two possible issues, and the rest either don't matter for the reconstruction back to 0 (but may when we forward apply things) or are likely harmless (4 issues that are very low priority).

## What it means

Fuzz is the number of lines ignored in the patch to apply it for the non-changing part. This suggests minor changes around the code that's changing. Each should be investigated. Often, it's white space, but sometimes it can be more.

Offset means that it expected the patch to start at line X but instead it started at X+offset. When offset is possitive, it indicates lines added (though offset 1 is quite often a blank line). When negative, it means code was deleted. The larger the number, the more cause for concern. Very large numbers can also just indicate code motion and not any substantial changes.

Here's an analysis of each of the errors.

### 179.log POSSIBLE ISSUE
        |*** /usr/src/ucb/ctags.c.old	Mon Feb 16 22:11:08 1987
        |--- /usr/src/ucb/ctags.c	Wed Feb 16 23:47:07 1994
        --------------------------
        Patching file usr/src/ucb/ctags.c using Plan A...
        Hunk #1 succeeded at 4.
        Hunk #2 succeeded at 94.
        Hunk #3 succeeded at 102.
        Hunk #4 succeeded at 178.
        Hunk #5 succeeded at 198.
        Hunk #6 succeeded at 224.
        Hunk #7 succeeded at 300.
        Hunk #8 succeeded at 310.
        Hunk #9 succeeded at 447.
        Hunk #10 succeeded at 699.
        Hunk #11 succeeded at 860.
        Hunk #12 succeeded at 913.
        Hunk #13 succeeded at 963.
        Hunk #14 succeeded at 1018 with fuzz 1 (offset -8 lines).
        done

This suggests a missing patch in ctags.c that removed 8 lines between lines 963 and 1018. There's no other patches to ctags.c in the tree, so this may be hard to track down.

### 159.log doesn't matter
        Patching QT/Makefile
        Hmm...  Looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |*** /usr/src/sys/GENERIC/Makefile.old	Sun Jul  4 21:27:00 1993
        |--- /usr/src/sys/GENERIC/Makefile	Sat Jan 22 16:39:46 1994
        --------------------------
        Patching file Makefile using Plan A...
        Hunk #1 succeeded at 109 with fuzz 2 (offset 27 lines).
        done
        Patching SMS/Makefile
        Hmm...  Looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |*** /usr/src/sys/GENERIC/Makefile.old	Sun Jul  4 21:27:00 1993
        |--- /usr/src/sys/GENERIC/Makefile	Sat Jan 22 16:39:46 1994
        --------------------------
        Patching file Makefile using Plan A...
        Hunk #1 succeeded at 109 with fuzz 2 (offset 27 lines).
        done

Changes to generated Makefile for both the QT and SMS files. QT disappears in the patch 93 or so. We regenerate SMS at patch 93, so these both can be ignored.

### 152.log Likely harmless
        Hmm...  The next patch looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |diff -c as.old/as19.s as/as19.s
        |*** as.old/as19.s	Tue Aug 22 20:14:29 1989
        |--- as/as19.s	Wed Dec 13 10:23:35 1989
        --------------------------
        Patching file as19.s using Plan A...
        Hunk #1 succeeded at 265 (offset 1 line).
        Hunk #2 succeeded at 313 (offset 1 line).
        Hunk #3 succeeded at 354 (offset 1 line).
        Hmm...  Ignoring the trailing garbage.
        done
        Hmm...  The next patch looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |diff -c as.old/as29.s as/as29.s
        |*** as.old/as29.s	Tue Aug 22 17:12:29 1989
        |--- as/as29.s	Sun Dec 24 15:06:33 1989
        --------------------------
        Patching file as29.s using Plan A...
        Hunk #1 succeeded at 230 (offset 1 line).
        Hunk #2 succeeded at 265 (offset 1 line).
        Hunk #3 succeeded at 284 (offset 1 line).
        Hmm...  Ignoring the trailing garbage.

I've looked into this and I think it's a blank line that's causing this at the start of the file, but I need to double check and confirm. The resulting as0.s and as2.s files are no different in later patches. This is likely harmless, but would be good to know why.

### 142.log doesn't matter

        Patching QT/Makefile
        Hmm...  Looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |*** /usr/src/sys/GENERIC/Makefile.old	Sun Jun  6 21:51:24 1993
        |--- /usr/src/sys/GENERIC/Makefile	Sun Jun  6 21:48:32 1993
        --------------------------
        Patching file Makefile using Plan A...
        Hunk #1 succeeded at 50 with fuzz 2 (offset 8 lines).
        done
        Patching SMS/Makefile
        Hmm...  Looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |*** /usr/src/sys/GENERIC/Makefile.old	Sun Jun  6 21:51:24 1993
        |--- /usr/src/sys/GENERIC/Makefile	Sun Jun  6 21:48:32 1993
        --------------------------
        Patching file Makefile using Plan A...
        Hunk #1 succeeded at 50 with fuzz 2 (offset 8 lines).
        done

Same files with offsets as for 159.log. Likely doesn't matter for same reasons. Though fuzz and offset is otherwise concerning and may indicate deeper issues that need to be investigated for the trip back through the patches.

### 124.log doesn't matter

        The text leading up to this was:
        --------------------------
        |*** /usr/src/sys/SMS/Makefile.old	Sat Dec 26 22:26:30 1992
        |--- /usr/src/sys/SMS/Makefile	Fri Mar 12 19:03:53 1993
        --------------------------
        Patching file usr/src/sys/SMS/Makefile using Plan A...
        Hunk #1 succeeded at 69 with fuzz 1 (offset 2 lines).
        Hmm...  Ignoring the trailing garbage.
        done
        Hmm...  Looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |*** /usr/src/sys/GENERIC/Makefile.old	Tue Dec 29 00:44:28 1992
        |--- /usr/src/sys/GENERIC/Makefile	Fri Mar 12 19:03:39 1993
        --------------------------
        Patching file usr/src/sys/GENERIC/Makefile using Plan A...
        Hunk #1 succeeded at 55 (offset 1 line).
        Hmm...  Ignoring the trailing garbage.
        done

The Makefiles (generated files) have become out of sync by one line. There's an additional line inserted in the first 55 lines of the template or similar. Given the amount of hand editing, I'll likely just document this as 'weird' in the end. For both of these, it's not a huge deal: we regenerate them at patch 93.

### 107.log POSSIBLE ISSUE

        The text leading up to this was:
        --------------------------
        |*** /usr/src/bin/sh/mac.h.old	Fri Dec 24 18:44:31 1982
        |--- /usr/src/bin/sh/mac.h	Mon Jan 18 08:45:24 1993
        --------------------------
        Patching file usr/src/bin/sh/mac.h using Plan A...
        No such line 62 in input file, ignoring
        Hunk #1 succeeded at 53 with fuzz 1 (offset -6 lines).
        done

This suggests a patch to mac.h prior to patch 107 that had a net loss of 6 lines in the first 53 lines of the file.

### 89.log likely harmless
        Hmm...  The next patch looks like a new-style context diff to me...
        The text leading up to this was:
        --------------------------
        |*** /usr/src/new/crash/route.c.old	Sat Aug 22 14:30:49 1987
        |--- /usr/src/new/crash/route.c	Wed Dec 23 20:09:44 1992
        --------------------------
        Patching file usr/src/new/crash/route.c using Plan A...
        Hunk #1 succeeded at 4.
        Hunk #2 succeeded at 403 with fuzz 1 (offset -3 lines).
        done

So there's a little bit of fuzz around this. Since /usr/src/new wasn't official until patch 80, maybe this is residual from that. Then again, there's this note in patch 89:
        The 'crash' program was updated only for completeness, the program
        has not run (or run correctly) since 2.10.1BSD (if not before that).
so I'll rate it likely harmless since the crash program likely didn't even work in 2.11BSD. That makes any reconstruction impossible to test, absent a tape surfacing...

### 84.log likely harmless

        The text leading up to this was:
        --------------------------
        |*** /sys/conf/KAZOO.old	Sun Dec 22 16:11:27 1991
        |--- /sys/conf/KAZOO	Thu Nov 19 21:06:53 1992
        --------------------------
        Patching file sys/conf/KAZOO using Plan A...
        Hunk #1 succeeded at 325 (offset -1 lines).
        Hunk #2 succeeded at 377 (offset -1 lines).
        Hmm...  The next patch looks like a new-style context diff to me...
        The text leading up to this was:
        The text leading up to this was:
        --------------------------
        |*** /sys/conf/VAX.old	Sun Dec 22 16:12:46 1991
        |--- /sys/conf/VAX	Tue Oct 13 20:46:49 1992
        --------------------------
        Patching file sys/conf/VAX using Plan A...
        No such line 370 in input file, ignoring
        Hunk #1 succeeded at 215 (offset -156 lines).

KAZOO is a best effort reconstruction. This suggests a small error in reconstructing it. Likely harmless, but maybe some attention is needed.

VAX is a no-effort reconstruction that's known to be badly off.
          
### 42.log likely harmless
        --------------------------
        |*** /usr/src/sys/conf/KAZOO.old	Wed Dec 19 10:12:43 1990
        |--- /usr/src/sys/conf/KAZOO	Sun Dec 22 16:11:27 1991
        --------------------------
        Patching file usr/src/sys/conf/KAZOO using Plan A...
        Hunk #1 succeeded at 336 (offset -1 lines).
        --------------------------
        |*** /usr/src/sys/conf/VAX.old	Sat Aug 12 21:58:07 1989
        |--- /usr/src/sys/conf/VAX	Sun Dec 22 16:12:46 1991
        --------------------------
        Patching file usr/src/sys/conf/VAX using Plan A...
        No such line 331 in input file, ignoring
        Hunk #1 succeeded at 177 (offset -155 lines).

Same as 84.log.

# Build Tests

We know that the 2.11BSD happened. If we're trying to reconstruct the sources to it, then they should build. We also know that at the time certain practices were in place. We need to determine if any build breakage was 'worked around' by these practices or if it indicates a problem in my reconstruction.

I established the following criteria:
 1. Does the breakage stop the build from completing? If so, then it's a bad reconstruction.
 1. Can a clean tree rebuild entirely?
 1. Could a 'dirty' tree cause the build to succeed? That is, if it complains something is missing, then is there a way to recreate the missing thing via make? If so, then one could pluasuably state that it could have gone unnoticed in the release. Rebuilding everything took more than a day, and according to notes in the patches, was undertaken about once a year.
 1. Is the breakage fixed later? Patches 106 to 116 fixed numerous build breakages and irregularities. Generally, I've opted to reconstruct as if those parts had been built by hand (mostly man pages, though I'm not sure what to do about the ns* utilties)
 1. Anything that it doesn't know to make?

## Known errors

### Don't know how to make clean. Stop.

There's a number of makefiles that don't know how to make clean. These errors
are all ignored by the build system, so are believed to be expected and
normal. This happens three times. But the root cause is in the
src/usr.lib/sendmail/lib/Makefile, which actually does not know how to make
clean.

### rmdir: tmp: no such file or directory Exit 1 (ignored)
        rmdir: tmp: No such file or directory
        *** Exit 1 (ignored)

In libc, the Makefiles use a tmp directory to do the build. It's removed, and rm returns an error since the file isn't there. This error is ignored and totally expected.

### Exit 1 (ignored) in me
        if [ ! -d /usr/lib/me ]; then  rm -f /usr/lib/me;  mkdir /usr/lib/me;  fi
        *** Exit 1 (ignored)

This blows away the installed macro environment styles and recreates them. This error is expected.

### Exit 1 (ignored) in f77

        mkstr - f77_strings xx equiv.c
        cc -S -w -DTARGET=PDP11 -DFAMILY=DMR -DHERE=PDP11 -DOUTPUT=BINARY  -DPOLISH=POSTFIX -DOVERLAID -DC_OVERLAY               xxequiv.c
        mv xxequiv.s equiv.s
        if [ X-i = X-n ]; then ed - equiv.s < :rofix; fi
        *** Exit 1 (ignored)

This is fixing up the error messages when building separate binaries. This error is expected due to the limitations in /bin/sh that's in 2.11BSD as shipped.

### Exit 10 (ignored) in jove

        ./setmaps < keymaps.txt > keymaps.c
        Warning: cannot find command "select-buffer-1".
        Warning: cannot find command "select-buffer-2".
        Warning: cannot find command "select-buffer-3".
        Warning: cannot find command "select-buffer-4".
        Warning: cannot find command "select-buffer-5".
        Warning: cannot find command "select-buffer-6".
        Warning: cannot find command "select-buffer-7".
        Warning: cannot find command "select-buffer-8".
        Warning: cannot find command "select-buffer-9".
        Warning: cannot find command "select-buffer-10".
        *** Exit 10 (ignored)

Another expected error.

### Exit 1 (ignored) in learn

        mkdir /usr/lib/learn  /usr/lib/learn/log  /usr/lib/learn/bin
        mkdir: /usr/lib/learn: File exists
        mkdir: /usr/lib/learn/log: File exists
        mkdir: /usr/lib/learn/bin: File exists
        *** Exit 1 (ignored)

Learn is trying to make directories that already exist. The lack of -p is what causes this.

### Exit 1 (ignored) find

        install -s find /usr/bin/find
        mkdir /usr/lib/find
        mkdir: /usr/lib/find: File exists
        *** Exit 1 (ignored)

This directory does exist, so this an expected error.

### Exit 1 (ignored) rwho

        mkdir /usr/spool/rwho
        mkdir: /usr/spool/rwho: File exists
        *** Exit 1 (ignored)

This directory does exist, so this an expected error.

### Exit 1 (ignored) ex
        mkdir /usr/preserve
        mkdir: /usr/preserve: File exists
        *** Exit 1 (ignored)

This directory does exist, so this an expected error.

### Exit 1 (ignored) battlestar
        install -c battlestar.6 /usr/man/man6/battlestar.6
        install: can't find battlestar.6.
        *** Exit 1 (ignored)

This file indeed does not exist here. It's one of the files that patch 106 moves back to live in /usr/src/games/battlestar. So this is expected and also fixed later.

### Exit 1 (ignored) phantasia
        mkdir /usr/games/lib/phantasia
        mkdir: /usr/games/lib/phantasia: File exists
        *** Exit 1 (ignored)

This directory does exist, so this an expected error.

### Exit 1 (ignored) warp
        mv /usr/games/warp /usr/games/warp.old
        mv: /usr/games/warp: Cannot access: No such file or directory
        *** Exit 1 (ignored)

this is expected. We remove warp as part of the build process so we don't wind up with a warp.old dated in 1994 on the image.

### Exit 1 (ignored) warp
        if test ! -f `./filexp /usr/games/lib/warp/warp.news`; then  cp warp.news `./filexp /usr/games/lib/warp`;  fi
        *** Exit 1 (ignored)

Also an expected exit value due to limitations in /bin/sh

### Exit 1 in nslookup
        for i in tools; do  (cd $i; make -k clean);  done
        sh: tools: bad directory
        *** Exit 1

This error is a real error. It's fixed in the 106-116 line of patches. It's
unclear if we should just build/install by hand or not for this one give the
high visibility of the missing pieces. It's highly likely that this was test
built, test installed before a full build, so the binaries were on the
system. This suggests that the build2.sh build orchestration should do that too.



