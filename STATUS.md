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
   replaced in 163. ar.c, randlib.c and nm.c also were extensively reworked as
   well.
 * MAKEDEV -- Patch 3 changes this, but it doesn't reverse apply cleanly to the
   tree we have, with 42 and 72 backed out as well. The reason for this is unknown.
 * usr/local/Makefile has decompr16 in it in 195. decompr16 was added to the tree
   at some point, but the makefile wasn't updated in the patcehes we have. But
   in patch 9, we add trace to the same line and the context diff says it shouldn't
   be there. Safe extraction for forward patching of the patches will
   highlight where this was added, it is hoped.
 * It looks like during the development process, /usr/include was updated, but
   /usr/src/include was not. Patch 175 copied /usr/include to /usr/src/include
   to synchronize things. It's unclear how many of these copies are needed
   and minor tweaks have been done to come close.
 * Patches 2 and 3 are problematic. They don't reverse apply cleanly for
   reasons  still under investigation.
   /etc/disktab is on the list, as is GENERIC's Makefile.
 * Edits to 2.11 install guide in 123 apparently omitted 4.t in the update, but
   the master tree was updated to reflect it.

123 files were recovered from 2.10.1BSD, and patched with known patches. 1 of
these needs to have a patch added. 1 (ld.c) is known bad. 21 need more
verification. 21 of these are the assembler. These are all now good and produce
identical files to what's in pl 195 when patched.  There's 57 include files that
were copied to put them in sync in patch 175, but it's unknown how many were out
of sync, and how badly they differed (also not in the table below). There's
several (10ish) redunant copies of man pages that I assume were identical for
this reconstruction (also not in the table below).

The standard I'm striving for is
 1. No changes in the patch series considered identical to 2.11
 2. Changes in the patch series that preserve data and reverse cleanly considered identical to 2.11
 3. Files deleted can be substituted with 2.10.1 files, absent evidence to the contrary.
 4. Patches in comp.bugs.2bsd is prima facia evidence that they changed between 2.10.1 and 2.11, absent stronger info
 5. Where possible, SCCS IDs should be checked to make sure that we don't have gaps in numbers between 2.10.1 and 2.11pl195 that might otherwise escape detection.
 6. Where the 2.11 patches mess up (and they do), document and use common sense. The bad patches haven't been documented here yet.

### Toolchain details

ld.c, ar.c, ranlib.c and nm.c were updated to move from the old binary archive
format to the new portable ar format. This feature was listed in the release
notes. The family tree shows code flowing into 2.11 from 4.3BSD and 4.3BSD
Tahoe. 4.3BSD Reno was out by the time 2.11 was released, so we can't preclude
code was pulled in from there.

ar.h, ar.c and ranlib.c are completely lost. All we know is they weren't derived
from 2.10.1BSD because it didn't support the new archive. We know that the new
code in patches 158-176 replaced them entirely, which means the diff was larger
than the new file. nm.c was moved, so we know the old and the new version. Let's
start there.

Let's turn our attention to nm.c. After patch 160 is unapplied, nm.c has the
following:

    static	char sccsid[] = "@(#)nm.c 4.7 5/19/86";

which is a 4BSD SCCS tag. Let's see if we can find it:

Rev | SCCS ID
----|---------
4.3BSD | "@(#)nm.c 4.7 5/19/86"
4.3BSD Tahoe | "@(#)nm.c 4.8 4/7/87"
4.3BSD Reno | "@(#)nm.c	5.6 (Berkeley) 6/1/90"

We can safely conclude that the nm.c in 2.11BSD came from 4.3BSD, possibly with
changes. A quick diff shows there are changes, but we have a good copy of nm.c
so we can conclude that other files likely came from 4.3BSD.

Next, if we audit ar.c. It is identical in 4.3BSD and 4.3BSD Tahoe (apart from a
single void cast added to quiet lint in the latter). The 4.3BSD Reno version
adds include of pathnames.h and uses the _PATH_TMP1 define, which is not present
even in a fully patched 2.11BSD. We can preclude 4.3BSD Reno as the source due
to this dependency. We can select either 4.3BSD or 4.3BSD Tahoe. Since they are
identical, and we got nm.c from 4.3BSD, we conclude that ar.c also came from
4.3BSD, though we'd get identical binaries from the 4.3BSD Tahoe version. ar.c
has no dependencies on a.out.h format, so we can likely just copy it from 4.3BSD
and have a program that works.

Next, turning our attention to ar.h. In 4.3BSD it's 444 bytes long. After the
patch, it's 2588 bytes long. This is consistent with the replacement we see in
patch 160. It's a bit acedemnic, though, as ar.h is identical in all the 4.3BSD
variants under consideration. We can likely just copy it from 4.3BSD.

ld.c is more troubling. We need to adjust it somehow. It lacks a SCCS id, so
we'll have to maybe rely on ealier diffs in 4BSD somehow, maybe between 3BSD and
4.0BSD where portable ar was introduced, though those diffs are extensive. Given
that the other items were pulled in from 4.3BSD, I have pulled the code from
there, being mindful of three things: (1) the ranlib stuff may be a weird hybrid
of the old/new since we still have the short symbol name length; (2) the vax has
various changes to get away from 16-bit ints; and (3) the vax has more extensive
reloc info than the pdp-11. After careful selection of what came from 2.10.1
and what came from 4.3BSD's ld.c, I think I have a good ld.c.

We learned from ld.c that ranlib must be producing the oldformat, but inside the
new portable ar format. It's is believd that this was accomplished by copying a
few lines in main that validates the magic number, the nextel, fixsize and
fixdate. There's no patches to validate this against, though. Given the evidence
of function copied from 4.3BSD in ld.c, it's safe to assume that's true here.

## All the hacks

Status | Source | Total | %
-------|--------|------|---
| BAD | 2.10.1BSD | 1 | 0.013%
| mostly | imp | 3 | 0.040%
| mostly | 2.10.1BSD | 1 | 0.013%
| Likely | 2.10.1BSD | 103 | 1.347%
| Likely | 2.11BSD | 14 | 0.186%
| GOOD | 2.10.1BSD | 23 | -

Total files in usr/src and etc is about 7500. At this point, only 1 file is known bad. 4 are mostly right, but there's something likely amiss. 117 are likely right, but haven't verified. 23 are known good via other means.

Status | Patch | File | From | Comments
-------|------|------|------|-------
| Likely | 187 | usr/src/include/syscall.h | 2.11BSD | Small tweak to allow subsequent patches to apply, maybe a missing chunk from another patch?
| Likely | 185 | usr/src/usr.bin/m4/Makefile | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 185 | usr/src/usr.bin/m4/m4.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 185 | usr/src/usr.bin/m4/m4y.y | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 178 | usr/src/sys/netinet/ip_acct.h | 2.10.1BSD + hack | Most likely contents, patched twice successfully, not relevant for 2.11bsd which is why it was removed
| Likely | 175 | usr/src/include/short_names.h | 2.10.1BSD | Most likely contents (short names)
| Likely | 175 | usr/src/include/arpa/inet.h | 2.11BSD + hack | fixup patch makes tiny hacks so this will 'unapply' so we're back to something closer to that was in 2.11BSD. It's likely, but not guaranteed to be perfect.
| Likely | 175 | usr/src/include/arpa/nameser.h | 2.11BSD + hack | fixup patch makes tiny hacks so this will 'unapply' so we're back to something closer to that was in 2.11BSD. It's likely, but not guaranteed to be perfect.
| Likely | 175 | usr/src/include/netdb.h | 2.11BSD + hack | fixup patch makes tiny hacks so this will 'unapply' so we're back to something closer to that was in 2.11BSD. It's likely, but not guaranteed to be perfect.
| Likely | 175 | usr/src/include/ndbm.h | 2.11BSD + hack | fixup patch makes tiny hacks so this will 'unapply' so we're back to something closer to that was in 2.11BSD. It's likely, but not guaranteed to be perfect.
| Likely | 175 | usr/src/include/setjmp.h | 2.11BSD + hack | fixup patch makes tiny hacks so this will 'unapply' so we're back to something closer to that was in 2.11BSD. It's likely, but not guaranteed to be perfect.
| Likely | 175 | usr/src/include/syscall.h | 2.11BSD + hack | fixup patch makes tiny hacks so this will 'unapply' so we're back to something closer to that was in 2.11BSD. It's likely, but not guaranteed to be perfect.
| Likely | 173 | usr/src/usr.binf/ranlib.c | 2.10.1BSD + 4.3BSD | Need to update the pdp-11 specific code we have from the vax version in 4.3BSD
| Likely | 171 | usr/src/ucb/symorder.c | 2.10.1BSD + 50 | Almost certainly correct, since the file was trivial and was patched in 50 and we have most of the text
| Likely | 171 | usr/src/ucb/tn3270/shortnames.h | 2.10.1BSD | Most likely contents (short names)
| Likely | 171 | usr/src/ucb/window/shortnames.h | 2.10.1BSD | Most likely contents (short names)
| Likely | 167 | usr/src/lib/libc/gen/nlist.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 164 | usr/src/etc/named/tools/nslookup/shortnames.h | 2.10.1BSD | Most likely contents (short names)
| Likely | 164 | usr/src/etc/named/named/shortnames.h | 2.10.1BSD | Most likely contents (short names)
| Likely | 164 | usr/src/etc/talkd/shortnames.h | 2.10.1BSD | Most likely contents (short names)
| Likely | 160 | usr/src/bin/csh/shortnames.h | 2.10.1BSD | Most likely contents (short names)
| Likely | 160 | usr/src/bin/ar.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 160 | usr/src/bin/ld.c | 2.10.1BSD + some 4.3BSD | Issues. Between 2.10.1 and 2.11 the new archive format came in and ld was updated. Updates for that not reconstructed yet.
| Likely | 160 | usr/src/bin/adb/dummy.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 160 | usr/src/bin/adb/mac.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 160 | usr/src/bin/adb/machine.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 160 | usr/src/bin/adb/mode.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 158 | usr/include/a.out.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 158 | usr/include/nlist.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 158 | usr/include/ar.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 158 | usr/include/ranlib.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 158 | usr/include/short_names.h | 2.10.1BSD | Most likely contents (short names)
| GOOD | 153 | usr/src/bin/as/as21.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as22.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as23.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as24.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as25.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as26.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as27.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as28.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 153 | usr/src/bin/as/as29.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as11.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as12.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as13.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as14.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as15.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as16.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as17.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as18.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/as19.s | 2.10.1BSD + earlier 2.11 and 2bsd patches | Forward patching works, no diffs to expected
| GOOD | 152 | usr/src/bin/as/Makefile | 2.10.1BSD + patches | Forward patching works, identical results
| Likely | 149 | usr/src/bin/mkdir.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 149 | usr/src/man/man1/mkdir.1 | 2.10.1BSD | Most likely contents (no 2bsd patches)
| Likely | 132 | usr/src/etc/named/tools/Makefile | 2.10.1BSD + 76 + 108 | Most likely contents, the patches from 76 and 108 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nsquery.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nstest.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/Makefile | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/nslookup.help | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/res.h | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/commands.l | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/debug.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/getinfo.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/list.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/main.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/send.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/skip.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/subr.c | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| Likely | 132 | usr/src/etc/named/tools/nslookup/shortnames.h | 2.10.1BSD + 76 | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
| mostly | 124 | usr/src/lib/libc/gen/popen.c | 2.10.1BSD | most likely content, *1 2bsd patch Nov 89*
| Likely | 124 | usr/src/lib/libc/gen/system.c | 2.10.1BSD | most likely content, no 2bsd patches
| Likely | 124 | usr/src/lib/libc/pdp/sys/wait.s | 2.10.1BSD | most likely content, no 2bsd patches
| Likely | 124 | usr/src/lib/libc/pdp/sys/wait3.s | 2.10.1BSD | most likely content, no 2bsd patches
| Likely | 124 | usr/src/man/man2/rtp.2 | 2.10.1BSD | most likely content, no 2bsd patches, rtp broken for a long time
| Likely | 124 | usr/src/man/man2/wait.2 | 2.10.1BSD | most likely content, no 2bsd patches
| Likely | 124 | usr/src/sys/sys/kern_rtp.c | 2.10.1BSD | most likely content, no 2bsd patches, rtp broken for a long time
| Likely | 124 | usr/src/lib/libc/pdp/com-2.9/rtp.s | 2.10.1BSD | Recovered from usr/src/lib/libc/pdp/compat-2.9/rtp.s so maybe there's other changes
| mostly | 123 | usr/doc/2.10/setup.2.11/4.t | imp | Hacked so that later ptaches apply cleanly. It's clear that 4.t was missing from this patch when sent. It's different in 2.11pl195 and this hack to the SCCS id is my proof of that. It's unclear if we can use the other changes to guess what else should be in this patch.
| Likely | 118 | usr/src/ucb/Mail/misc/Mail.rc | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/misc/Mail.help | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/misc/Mail.tildehelp | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/aux.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/cmd1.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/cmd2.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/cmd3.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/cmdtab.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/collect.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/config.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/def.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/edit.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/fio.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/configdefs.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/glob.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/fmt.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/getname.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/head.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/lex.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/list.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/main.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/Makefile | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/names.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/optim.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/local.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/popen.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/quit.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/send.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/sigretro.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/strings.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/temp.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/rcv.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/tty.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/v7.local.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/vars.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/version.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/v7.local.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/sigretro.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/Makefile.11 | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 118 | usr/src/ucb/Mail/strings | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
| Likely | 104 | usr/src/new/shar/getopt.3 | 2.11BSD | From redundant copy
| Likely | 104 | usr/src/etc/ftpd/getusershell.3 | 2.11BSD | From redundant copy
| Likely | 104 | usr/src/usr.lib/sendmail/aux/logger.1 | 2.11BSD | From redundant copy
| Likely | 104 | usr/src/usr.lib/sendmail/doc/mailaddr.7 | 2.11BSD | From redundant copy
| Likely | 104 | usr/src/usr.lib/sendmail/doc/sendmail.8 | 2.11BSD | From redundant copy
| Likely | 104 | usr/src/usr.lib/sendmail/aux/vacation.1 | 2.11BSD | From redundant copy
| Likely | 104 | usr/src/man/man8/tftpd.8 | 2.11BSD | From redundant copy
| mostly | 80 | usr/src/local/Makefile | imp | decompr16 was added to the tree at some point (it's unclear when at the moment, we'll discover it when it goes forward). So we have a small fixup patch to remove it here so that patch 4 applies cleanly.
| Likely | 17 | usr/src/lib/pcc/INDEX | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 17 | usr/src/lib/pcc/:rofix | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 17 | usr/src/lib/pcc/fort.h.vax | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/READ_ME | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/SHELL | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/lint.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/lmanifest | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/lpass2.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/macdefs | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/cgram.s | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/cgram.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/Ovmakefile | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/allo.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| Likely | 14 | usr/src/usr.bin/lint/Makefile | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
| BAD | 3 | dev/MAKEDEV | imp | Patch doesn't work, so it's just omitted
| regen | 3 | usr/src/sys/GENERIC/localopts.h | imp | Patch doesn't work, so omitted... This is a generated file that was customized. regen is fine for the vanilla system we're recovering.
| regen | 2 | usr/src/sys/GENERIC/Makefile | imp | Patch 2/b.1 doesn't work, may need to investigate why, but for now just regenerating.
| GOOD | 2 | etc/disktab | imp | etc/disktab and usr/src/sys/pdpdist/disktab are out of sync. Just remove patch b.16 since that issue was corrected in patch 78, but I didn't uncorrect it there, so the right thing is to delete it there and we'll be in sync at pl0
| GOOD | 2 | usr/src/sys/mdec/bruboot.s | imp | Patch 2/b.4 doesn't unapply to this one file bruboot.s. It looks like a hack made it into the master tree for our pl195 we started with because the Rome 11/70 didn't do the right thing. Backed that out by hand with 2.mu
| mostly | 0 | usr/src/sys/conf/KAZOO | imp | KAZOO disappeared from 2.11 before pl 195 but after pl 84 where it was referenced. I reconstructed this by doing a diff between GENERIC and KAZOO in 2.10.1, then apply that to a copy of GENERIC to KAZOO in 2.11 and hand applied a few patches, then hacked it to be consistent with patches 42 and 84. Maybe I need a plausably speculative category.

## Patch Fuzz Report
patch | Fuzz / offset | why
------|---------------|-----
2|Hunk #1 succeeded at 45 (offset -4 lines). | bruboot.s, likely due to other hacks
42|Hunk #1 succeeded at 336 (offset -1 lines). | KAZOO kernel config
42|Hunk #1 succeeded at 177 (offset -155 lines). | VAX kernel config
84|Hunk #1 succeeded at 325 (offset -1 lines). | KAZOO
84|Hunk #2 succeeded at 377 (offset -1 lines). | KAZOO
84|Hunk #1 succeeded at 215 (offset -156 lines). | VAX
89|Hunk #2 succeeded at 403 with fuzz 1 (offset -3 lines). | usr/src/new/crash/route.c
107|Hunk #1 succeeded at 53 with fuzz 1 (offset -6 lines). | usr/src/bin/sh/mac.h
152|Hunk #1 succeeded at 265 (offset 1 line). | as19.s
152|Hunk #2 succeeded at 313 (offset 1 line). | as19.s
152|Hunk #3 succeeded at 354 (offset 1 line). | as19.s
152|Hunk #1 succeeded at 230 (offset 1 line). | as29.s
152|Hunk #2 succeeded at 265 (offset 1 line). | as29.s
152|Hunk #3 succeeded at 284 (offset 1 line). | as29.s
179|Hunk #14 succeeded at 1018 with fuzz 1 (offset -8 lines). | usr/src/ucb/ctag.c

So now we need to discover if we're seeing these issues due actual issues, or if
they reflect mistakes made when the patches were generated.

KAZOO is a file I've reconstructed, so I'm missing a line.  VAX, however, isn't
so something else is in play here. I think it may indicate a missing patch
and/or local changes that deletes those 155 lines.

sh, mac, tags are likely local tweaks since none of those are reconstructed, nor
should any have any information loss.

bruboot.s is a know out-of-sync file that had 2 lines added as a hack somewhere long the way.

as[12]9.s is a complete mystery to me, because there's no diffs with as0.s and
as2.s which I have and I applied all the right patches to as[12]9.s. I don't get
why there's any offset at all. There's nothing obvious from quick inspection.

More data on how to interpret these results will be obtained when we try to roll
forward all the way to the most current patch 469.
