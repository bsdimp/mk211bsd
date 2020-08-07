# ur211BSD notes

Various notes about the current state of things.

# Latest bad-date info

Filtered set of files that have bad dates in the final build.

Size | date | file | notes
-----|------|------|------
 64184 | Jan 16  1994 | ./usr/games/lib/battle_strings | needs to be installed by hand
    75 | Jan 16  1994 | ./usr/games/words | OK, was in old source, not sure why its date changes
     4 | Feb 16  1994 | ./usr/lib/uucp/SEQF
    76 | Jul 12  1994 | ./usr/lib/uucp/L.sys
 66625 | Jun 12  1994 | ./usr/lib/find/find.codes
   209 | Dec 30  1992 | ./usr/lib/crontab
   622 | Jul 12  1994 | ./usr/lib/aliases
  1241 | Jan  9  1994 | ./usr/man/makewhatis.sed
   873 | Jan  9  1994 | ./usr/man/manroff
 34557 | Jul 17  1994 | ./usr/man/whatis
   109 | Jan 15  1994 | ./usr/man/man.template
     2 | Jul 12  1994 | ./usr/msgs/bounds
    10 | Jul 11  1994 | ./usr/spool/at/lasttimedone
     0 | Dec 28  1991 | ./usr/spool/lpd/errs
     0 | Jul 12  1994 | ./usr/spool/lpd/acct
     4 | Jun 21  1994 | ./usr/spool/lpd/.seq
    25 | Jun 21  1994 | ./usr/spool/lpd/status
     0 | Jul 12  1994 | ./usr/spool/mqueue/syslog
     0 | Jul 12  1994 | ./usr/spool/uucp/LOGFILE
    62 | Apr 28  1991 | ./usr/src/sys/pdpstand/maketape.data
  1516 | Jan  6  1994 | ./usr/src/include/a.out.h
  1389 | Jan  6  1994 | ./usr/src/include/nlist.h
   849 | Apr 26  1993 | ./usr/src/etc/named/master/root.cache
  2962 | Jun 25  1991 | ./usr/src/lib/mip/manifest.h
  1306 | Aug  3  1991 | ./usr/src/lib/mip/ndu.h
   526 | Jul 19  1991 | ./usr/src/lib/mip/onepass.h
  3095 | Jul 30  1991 | ./usr/src/lib/pcc/Makefile.twopass
   733 | Jan 20  1993 | ./usr/src/lib/Makefile
  9826 | Jun 10  1992 | ./usr/src/new/rn/Pnews
  1590 | Jun 10  1992 | ./usr/src/new/rn/config.sh
  2836 | Jun 10  1992 | ./usr/src/new/rn/config.h
  5615 | Jun 10  1992 | ./usr/src/new/rn/Rnmail
  3534 | Jun 10  1992 | ./usr/src/new/rn/newsetup
  1375 | Jun 10  1992 | ./usr/src/new/rn/newsgroups
  1143 | Jun 10  1992 | ./usr/src/new/rn/newsnews
   625 | Jan 22  1993 | ./usr/src/new/crash/Makefile
 13181 | Dec 31  1993 | ./usr/src/usr.lib/sendmail.MX/src/daemon.c

## Observations

So we still have 18 files in /usr/src to contend with. 7 of them are rn files that likely need to be regenerated with an old date from the ur2.11BSD tree.

maketape.data is super close in time, and likely can be ignored.

/usr/src/include likely needs to be copied from /usr/include

5 files appear releated to pcc.

master/root.cache is oddly out of place and needs investigating.

src/lib/Makefile suggests a missing patch of some flavor or just an editor oops.

src/new/crash/Makefile likewise suggest same

and the daemon.c one is weird.

