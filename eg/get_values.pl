#!/usr/bin/perl

use CDB_Perl::Read;
use strict;

my $file = shift or die "$0 file.cdb\n";
my $key = shift;

#print join", ",CDB::hash($key);

my $cdb = CDB_Perl::Read->new($file, 'all');

if (!$key) {
	while ($key = <>) {
		if (!defined($key)) {
			exit;
		}
		chomp($key);
		print_key($key);
	}
}
else {
	print_key($key);
}

sub print_key {
	my @values = $cdb->get_values($key);
	print join "\n",@values;
	print "\n";
}
