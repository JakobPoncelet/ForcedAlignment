#!/usr/bin/perl

# Script name: iso8859-to-utf8.pl (filename)

# Description:
# Perl script to convert files from ISO-8859-1 to UTF-8 (Unicode). Useful to convert accents from old files to the new utf8 format.
#
# Created by: Rodrigo Siqueira (rsiqueira at gmail)
#
# Creation date: 31/mai/2011
#
# Updates:
#   15/jul/2011 - keeps original file time stamp ($keep_times=1)
#   28/jul/2011 - keeps original file permission chmod ($keep_permissions=1)

# TODO: Should no convert agin if the file was already converted (eg: test file content to see if it is already utf8)

use strict;
use Data::Dumper;
use feature 'say';

my $debug = 0;

my $keep_times = 1;
my $keep_permissions = 1;

my @files = @ARGV;

if (!$files[0]) {
  die ("Usage: $0 filename\n");
}

####

foreach my $file (@files) {

  if (!-f $file) {
    die ("ERROR: '$file' is not a file: $!\n");
  } elsif (!-r $file) {
    die("ERROR: Could not read ($file): permission denied?\n");
  }

  my $pid = $$;

  my $file_new_tmp = $file . ".new-$pid";

  my $exe = "iconv -f US-ASCII -t UTF-8 \"$file\" > \"$file_new_tmp\"";
  if ($debug > 1) {
    say "$exe";
  }
  my $ok = `$exe`;

  # say "Converting '$file' from us-ascii to utf-8... ";

  if (!-e $file_new_tmp) {
    die "ERROR: Could not create file_new ($file_new_tmp): $!\n";
  }

  my ($atime, $mtime, $ctime) = (stat($file))[8,9,10]; # Read datetime from original file

  my $chmod = sprintf("%04o", (stat($file))[2] & 07777 ); # E.g.: 0755

  if (-s $file_new_tmp) {
    my $ok_rename = (rename $file_new_tmp, $file);  # Copy new file over original file
    if ($debug > 1) {
      say "rename $file_new_tmp, $file";
    }

    if (!$ok_rename) {
      say STDOUT "ERROR: Could not rename '$file_new_tmp' to '$file': $!";
    }
  } else {
    die "ERROR: file_new_tmp ($file_new_tmp) zero bytes? $!\n";
  }

  if ($keep_times) {
    my ($sec,$min,$hour,$mday,$month,$year,$wday,$yday,$isdst) = localtime($mtime);
    if ($debug) {
      $year += 1900;
      $month++;
      $month = sprintf("%02d", $month);
      $mday  = sprintf("%02d", $mday);
      $hour  = sprintf("%02d", $hour);
      $min   = sprintf("%02d", $min);
      $sec   = sprintf("%02d", $sec);
      say "Keeping original date: $year-$month-$mday $hour:$min:$sec";
    }
    utime $atime, $mtime, $file;
  }

  if ($keep_permissions) {
    if ($debug > 1) {
      say "Keeping original permissions: chmod $chmod";
    }
    my $ok = chmod oct($chmod), $file;
  }

}

# say "Done!";

### END ###
