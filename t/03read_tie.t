# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use Test::More tests => 4;
BEGIN { use_ok('CDB_Perl::Read') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

chdir('tmp') or die "Could not change current directory. $!\n";
our %cbd;

ok(tie (%cdb, CDB_Perl::Read, 'write.cdb'), 'Create tied hash');
ok($cdb{'#CDB'} eq '#Perl','Reading single value');
our %data;
cdb_hash();
ok(check_file(), 'Checking values in written cdb using tied CDB');

sub check_file{
	while(my ($k,$v) = each(%data)){
		if($cdb{$k} ne $v){
			return;
		}
	}
	return 1;
	while(my ($k,$v) = each(%cdb)){
		if($data{$k} ne $v){
			return;
		}
	}
	return 1;
}

sub cdb_hash{
	open KEYS,'<','keys' or die;
	open VALUES,'<','values' or die;
	
	while(my $key = <KEYS>){
		my $value = <VALUES>;
		chomp($key, $value);
		if(!exists($data{$key})){
			$data{$key} = $value;
		}
	}
	return \%data;
}
