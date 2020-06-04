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

## All the files recovered from 2.10.1
Patch | File | From | status
------|------|------|-------
Patch 185 | usr/src/usr.bin/m4/Makefile | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 185 | usr/src/usr.bin/m4/m4.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 185 | usr/src/usr.bin/m4/m4y.y | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 178 | usr/src/sys/netinet/ip_acct.h | 2.10.1BSD | Most likely contents, patched twice successfully, not relevant for 2.11bsd which is why it was removed
Patch 175 | usr/src/include/short_names.h | 2.10.1BSD | Most likely contents (short names)
Patch 173 | usr/src/usr.bin/ranlib.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 171 | usr/src/ucb/symorder.c | 2.10.1BSD | Almost certainly correct, since the file was trivial and was patched in 50 and we have most of the text
Patch 171 | usr/src/ucb/tn3270/shortnames.h | 2.10.1BSD | Most likely contents (short names)
Patch 171 | usr/src/ucb/window/shortnames.h | 2.10.1BSD | Most likely contents (short names)
Patch 167 | usr/src/lib/libc/gen/nlist.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 164 | usr/src/etc/named/tools/nslookup/shortnames.h | 2.10.1BSD | Most likely contents (short names)
Patch 164 | usr/src/etc/named/named/shortnames.h | 2.10.1BSD | Most likely contents (short names)
Patch 164 | usr/src/etc/talkd/shortnames.h | 2.10.1BSD | Most likely contents (short names)
Patch 160 | usr/src/bin/csh/shortnames.h | 2.10.1BSD | Most likely contents (short names)
Patch 160 | usr/src/bin/ar.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 160 | usr/src/bin/ld.c | 2.10.1BSD | <span style="color:red">Issues. changes between 2.10.1 and 2.11 and we don't have them all.</span>
Patch 160 | usr/src/bin/adb/dummy.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 160 | usr/src/bin/adb/mac.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 160 | usr/src/bin/adb/machine.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 160 | usr/src/bin/adb/mode.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 158 | usr/include/a.out.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 158 | usr/include/nlist.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 158 | usr/include/ar.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 158 | usr/include/ranlib.h | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 158 | usr/include/short_names.h | 2.10.1BSD | Most likely contents (short names)
Patch 153 | usr/src/bin/as/as21.s | 2.10.1BSD | <span style="color:yellow">As consolidated and we can test if these reconstructions are correct. haven't tested it.</span>
Patch 153 | usr/src/bin/as/as22.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 153 | usr/src/bin/as/as23.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 153 | usr/src/bin/as/as24.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 153 | usr/src/bin/as/as25.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 153 | usr/src/bin/as/as26.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 153 | usr/src/bin/as/as27.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 153 | usr/src/bin/as/as28.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 153 | usr/src/bin/as/as29.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as11.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as12.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as13.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as14.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as15.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as16.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as17.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as18.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/as19.s | 2.10.1BSD | <span style="color:yellow">ditto</span>
Patch 152 | usr/src/bin/as/Makefile | 2.10.1BSD | Most likely contents, might be able to reconstruct it better
Patch 149 | usr/src/bin/mkdir.c | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 149 | usr/src/man/man1/mkdir.1 | 2.10.1BSD | Most likely contents (no 2bsd patches)
Patch 132 | usr/src/etc/named/tools/Makefile | 2.10.1BSD | Most likely contents, the patches from 76 and 108 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nsquery.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nstest.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/Makefile | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/nslookup.help | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/res.h | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/commands.l | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/debug.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/getinfo.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/list.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/main.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/send.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/skip.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/subr.c | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 132 | usr/src/etc/named/tools/nslookup/shortnames.h | 2.10.1BSD | Most likely contents, the patches from 76 reverse apply, no 2bsd patches
Patch 124 | usr/src/lib/libc/gen/popen.c | 2.10.1BSD | most likely content, <span style="color:red"> 1 2bsd patch Nov 89</span>
Patch 124 | usr/src/lib/libc/gen/system.c | 2.10.1BSD | most likely content, no 2bsd patches
Patch 124 | usr/src/lib/libc/pdp/sys/wait.s | 2.10.1BSD | most likely content, no 2bsd patches
Patch 124 | usr/src/lib/libc/pdp/sys/wait3.s | 2.10.1BSD | most likely content, no 2bsd patches
Patch 124 | usr/src/man/man2/rtp.2 | 2.10.1BSD | most likely content, no 2bsd patches, rtp broken for a long time
Patch 124 | usr/src/man/man2/wait.2 | 2.10.1BSD | most likely content, no 2bsd patches
Patch 124 | usr/src/sys/sys/kern_rtp.c | 2.10.1BSD | most likely content, no 2bsd patches, rtp broken for a long time
Patch 124 | usr/src/lib/libc/pdp/com-2.9/rtp.s | 2.10.1BSD | <span style="color:yellow">Recovered from usr/src/lib/libc/pdp/compat-2.9/rtp.s so maybe there's other changes</span>
Patch 118 | usr/src/ucb/Mail/misc/Mail.rc | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/misc/Mail.help | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/misc/Mail.tildehelp | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/aux.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/cmd1.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/cmd2.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/cmd3.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/cmdtab.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/collect.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/config.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/def.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/edit.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/fio.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/configdefs.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/glob.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/fmt.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/getname.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/head.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/lex.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/list.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/main.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/Makefile | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/names.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/optim.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/local.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/popen.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/quit.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/send.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/sigretro.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/strings.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/temp.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/rcv.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/tty.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/v7.local.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/vars.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/version.c | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/v7.local.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/sigretro.h | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/Makefile.11 | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 118 | usr/src/ucb/Mail/strings | 2.10.1BSD | Most likely contents (hasn't been updated for a while), no 2bsd patches
Patch 17 | usr/src/lib/pcc/INDEX | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 17 | usr/src/lib/pcc/:rofix | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 17 | usr/src/lib/pcc/fort.h.vax | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/READ_ME | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/SHELL | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/lint.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/lmanifest | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/lpass2.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/macdefs | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/cgram.s | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/cgram.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/Ovmakefile | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/allo.c | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
Patch 14 | usr/src/usr.bin/lint/Makefile | 2.10.1BSD | Most likely contents, no 2bsd patches, comments that this hasn't changed in a while
