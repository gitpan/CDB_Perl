#!/usr/bin/perl

#print information abou nonempty hash tables in a cdb
#usefull for debug

use Data::Dumper;

use strict;

my $fname = shift or die "$0 filename\n";

my $file;
open($file,'<:raw',$fname);

my $head;
read($file,$head,2048);
my @head = unpack("V512",$head);

for(my $i=0; $i<256; ++$i){
	next unless($head[2*$i+1]);
	print "$i\t=>\t";
	print_table(@head[2*$i,2*$i+1]);
}


sub print_table{
	my ($pos, $len) = @_;
	seek($file,$pos,0);
	my $data;
	read($file, $data, $len*2*4);
	print ((join ',',(unpack"V".($len*2),$data))."\n");
}
