# ur2.11BSD Testing

This tries to document the tests that I'm using to validate my reconstruction

## Patch Consistent

The very first test is 'is the reconstruction consistent with the patches'. This means, does anything in the patches contradict what has been reconstructed. Examples of this are the patches not apply, applying with unexplained fuzz or line number deltas.

Now that all the patches apply w/o error, I've narrowed the scope of this patch. The test is to grep for the words offset or fuzz in the log files:

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

### What it means

Fuzz is the number of lines ignored in the patch to apply it for the non-changing part. This suggests minor changes around the code that's changing. Each should be investigated. Often, it's white space, but sometimes it can be more.

Offset means that it expected the patch to start at line X but instead it started at X+offset. When offset is possitive, it indicates lines added (though offset 1 is quite often a blank line). When negative, it means code was deleted. The larger the number, the more cause for concern. Very large numbers can also just indicate code motion and not any substantial changes.

XXX going backwards offset may be flipped, need to check and verify.

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
so I'll rate it likely harmless.

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
