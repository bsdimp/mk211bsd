# 2.11BSD Recovery Project

Almost all of the BSD releases survive to the present. Except one major on: 2.11BSD.

But wait, 2.11BSD is everywhere today. That's true. But it's 2.11BSD pl 470 or
some other patched version. The original release has been lost in the sands of
time.

Why? Well, the 2BSD series was released for the PDP-11. It only ran on the
PDP-11 (until modern times when RetroBSD used it to run on MIPS-based PIC
microcontrollers). The PDP-11 were low-end mini computers once the VAX were
released. They had very little disk space, and tapes were expensive. This meant
that tapes were reused, and disk contents were pruned often. Adding to the
confusion is that the 2.11BSD tapes were expensive when originally released. One
needed to but an AT&T Unix license, which was hundreds of dollars.

So, these factors have conspired to mena that 2.11BSD pl 195 is the earliest
surviving 2.11BSD. We have 2.10BSD and 2.10.1BSD, but nothing until the
2.11BSDpl195. A big reason for this is that in the 160s or so in the patch
stream the compiler was modernized and nobody wanted the older version because
the amount of software that could be compiled was diminishing year by year.

## Why?

But can't you run the patches backwards? We have them all? Why is this project
even needed?

Good question. The "patches" in the 2.11BSD series weren't modern unified diffs
that retained all the info, even when deleting files. Oftne times, they were
shell scripts that removed the files. Or did other things that destroyed
information. Destroyed information is impossible to recover, so it's hopeless.

## But is it?

Well, to get a 100% perfect recreation is impossible. But how close can we get?
That's what this project is doing. We know that 95% of the files are the same as
they were in 2.11BSD. We know that many files that were destroyed are the same
as they were in 2.10.1BSD, so we can recover them. Others came from 4.3BSD. Only
a few files need 'restoration' work.

# Status

We've worked our way back to 2.11BSD pl 0. Or at least a possible 2.11BSD pl
0. Now we have to prove it can create a bootable system and all the patches can
apply to it to get back to an identical 2.11BSD pl 195 we have. Work is underway
to roll things forward in an automated way (starting with 2.11BSD pl 195 and
clawing our way back to 2.11BSD pl 0, rebuilding pl 0 and then moving forward).

So there' sa lot ot do still to prove this out, and I need to write the paper to
go along with it.

