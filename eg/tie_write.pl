#!/usr/bin/perl

use lib '../lib';

require CDB_Perl::Write;

my $fname = shift or die "$0 fname";

my %data;
tie %data,'CDB_Perl::Write', $fname;

while(<>){
	chomp;
	my ($k,$v) = split /\t/,$_,2;
	$data{$k}=$v;
}
#cdb finished when %data goes out of scope (DESTROY method)
