# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use Test::More tests => 5;
BEGIN { use_ok('CDB_Perl::Read') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

chdir('tmp') or die "Could not change current directory. $!\n";

my $ak = '#test_array';
my @av;
push @av,"array_value_$_" for(1..100);

our $cbd;

ok($cdb = CDB_Perl::Read->new('write.cdb'), 'Create reader object');
ok(eq_array([$cdb->get_values('#CDB')], ['#Perl']),'Reading single value');
ok(eq_array([($cdb->get_value($ak))], \@av),'Reading multiple values');
ok(check_cdb(), 'Checking values in written cdb');

sub check_cdb{
	open KEYS,'<','keys' or die;
	open VALUES,'<','values' or die;
	
	my %data=();

	while(my $key = <KEYS>){
		my $value = <VALUES>;
		chomp($key, $value);
		if(!exists($data{$key})){
			$data{$key} = [$value];
		}else{
			push @{$data{$key}},$value;
		}
	}

	#now see if they are all defined
	while( my($k,$v) = each(%data) ){
		if( $cdb->get_values($k) != @$v){
			return;
		}
	}
	return 1;
}
