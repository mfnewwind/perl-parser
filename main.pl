#!/usr/bin/perl

use strict;
use utf8;

my $ret = `perl script/parser.pl $ARGV[0] 2>&1`;
if ($ret =~ m/^\[.*\]$/) {
    print '{"status":"success","result":' . $ret . '}';
}
else {
    print '{"status":"fail","result":' . $ret . '}';
}
