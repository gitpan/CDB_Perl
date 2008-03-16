# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use Test::More ('no_plan');
BEGIN { use_ok('CDB_Perl::Read') };
use bytes;
use strict;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

chdir('external') or die "Could not change current directory. $!\n";
our $cbd;

my @multiple_values = ('1','2','2','3','3','3','4','4','4','4','5','5','5','5','5');

ok(my $cdb = CDB_Perl::Read->new('external.cdb'), 'Create reader object');
ok(eq_array([$cdb->get_values('claudio')], ['valente']),'Reading single value');
ok(eq_array([$cdb->get_values('manuel')], ['neves']),'Reading single value');
ok(eq_array([$cdb->get_values('multiple')], \@multiple_values),'Reading multiple values');

my @values = $cdb->get_value('multiple');

ok(eq_array(\@values, \@multiple_values),'Reading multiple values using array context');

@values = ();
$values[0] = $cdb->get_value('multiple');

while(my $v = $cdb->get_next()){
	push @values, $v;
}
ok(eq_array(\@values, \@multiple_values),'Reading multiple values using get_next');

#now compare all keys

open my $in, '<:raw', 'external.dump' or die "can't open dump file";

my %dump = ();

while (my $line=<$in>){
	chomp($line);
	last if $line eq '';

	my ($len, $data) = split /:/,$line,2;
	my ($l1, $l2) = split /,/,$len,2;
	$l1+=0;
	$l2+=0;
	my $k = substr($data,0,$l1);
	my $v = substr($data, $l1+2,$l2);
	if(exists $dump{$k}){
		my @v = @{$dump{$k}};
		push @v, $v;
		$dump{$k} = \@v;
	}else{
		$dump{$k} = [$v];
	}
}

while (my($k,$v) = each(%dump)){
	ok(eq_array([$cdb->get_values($k)], $v),"reading key [$k]");
}
