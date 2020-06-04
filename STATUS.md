# ur2.11BSD Status

This project aims to recreate 2.11BSD release from existing patches and other
sources of information. Patches exist back to the start, and we have a 2.11BSD
pl 195 tape.

## So why isn't it done already

The problem is that these patches aren't modern patches. Were they modern
unified diffs, this would be a very simple matter and we'd be done. However,
that's not the case. These are patches from the early 1990s when bytes mattered
on machines that were small. So many of them are scripts. Worse, many of them
just delete the old file and create a full new one.

## So what do you do about it?

So, 2.11BSD grew out of 2.10.1BSD (it was originally called 2.10.2SMS
BSD). There's a continuous series of development of these patches from 2.10.1BSD
to 2.11BSD. Some were posted to the comp.bugs.2bsd news group. Some are just
imports of the 4.3BSD sources.

As of this writing, we can make a plausable reconstruction for most of the 123
files that were deleted or otherwise replaced. And in most of those cases, we're
likely spot on, or within a tiny epsilon of the original 2.11 tape.

## Almost? How close?

It's hard to say for sure, but my best guess is that the following files are the
ones that are likely lost.

 * ld.c -- ld was written in patches 158 to 176. It was deleted in patch 160 and
   replaced in 163
 * MAKEDEV -- Patch 3 changes this, but it doesn't reverse apply cleanly to the
   tree we have, with 42 and 72 backed out as well. The reason for this is unknown.
 * usr/local/Makefile has decompr16 in it in 195. decompr16 was added to the tree
   at some point, but the makefile wasn't updated in the patcehes we have. But
   in patch 9, we add trace to the same line and the context diff says it shouldn't
   be there.
 * It looks like during the development process, /usr/include was updated, but
   /usr/src/include was not. Patch 175 copied /usr/include to /usr/src/include
   to synchronize things. It's unclear how many of these copies are needed
   and minor tweaks have been done to come close.
 * as -- also was rewritten. We have a number of patches from comp.bugs.2bsd
   that we've pulled in and the reverse patch now applies. We've not tested
   it forwards yet.
 * Patches 2 and 3 are problematic. They don't reverse apply cleanly for
   reasons  still under investigation. this means that bruboot.s is in limbo
   until we can sort it out (it won't reverse apply, suggesting a local hack).
   /etc/disktab is on the list, as is GENERIC's Makefile.
 * minor edits to 2.11 install guide apparently omitted 4.t in the update, but
   the master tree was updated to reflect it.

And I've not verified that any of the 123 files we've recovered from 2.10.1BSD
have patches in the newsgroup.

So a quick sensus suggests we're < 100 files away (maybe less than 10) from what
the 2.11BSD tape as shipped looked like. This is out of 11,242 files that I
think are on the tape (well likely a few less since this includes removed
binaries). So 100/11200 is 0.89% and 10/11200 is 0.089%. We're at least 99.1%
recovered, maybe as much as 99.9%

