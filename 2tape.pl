#!/usr/bin/perl
use strict;
# Written by Will Senn. Create a bootable SimH tap file to install the system.
# Inspired by various Perl scripts and based on Hellwig Geisse's mktape.c
#
# modified 20171012 binmode required for windows use
# This is just a hack to mount tapes for the 2.11 project

my @files = ("src.tar");
my @blkszs = (10240);

my $outfile = "src.tap";

my $EOF = "\x00\x00\x00\x00";
my $EOT = "\xFF\xFF\xFF\xFF";

open(OUTFILE, ">$outfile") || die("Unable to open $outfile: $!\n");
binmode(OUTFILE);
for(my $i = 0; $i <= $#files; $i++) {
   my ($bytes, $blocksize, $buffer, $packedlen, $blockswritten, $file) = 0;

   $file = $files[$i];
   $blocksize = $blkszs[$i];
   $packedlen = pack("V", $blocksize);

   open(INFILE, $file) || die("Unable to open $file: $!\n");
   binmode(INFILE);
   while($bytes = read(INFILE, $buffer, $blocksize)) {
     $buffer .= $bytes < $blocksize ? "\x00" x ($blocksize - $bytes) : "";
     print OUTFILE $packedlen, $buffer, $packedlen;
     $blockswritten++;
   }
   close(INFILE);
   print OUTFILE $EOF;
   printf "%s: %d bytes = %d records (blocksize %d bytes)\n", $file, $blockswritten * $blocksize, $blockswritten, $blocksize;
}
print OUTFILE $EOT
