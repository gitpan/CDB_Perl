#!/usr/bin/perl

use lib '../lib';

require CDB_Perl::Read;

my $fname = shift or die "$0 fname";

my %data;
tie %data,'CDB_Perl::Read', $fname;

while(my ($k,$v) = each(%data)){
	print "[$k] => [$v]\n";
}
