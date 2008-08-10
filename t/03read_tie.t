use Test::More tests => 4;
BEGIN { use_ok('CDB_Perl::Read') };
use strict;

chdir('tmp') or die "Could not change current directory. $!\n";

ok(tie (my %cdb, 'CDB_Perl::Read', 'write.cdb'), 'Create tied hash');
ok($cdb{'#CDB'} eq '#Perl','Reading single value');
my %data;
cdb_hash();
ok(check_file(), 'Checking values in written cdb using tied CDB');

sub check_file{
	while(my ($k,$v) = each(%data)){
		if($cdb{$k} ne $v){
			return;
		}
	}
	return 1;
}

sub cdb_hash{
	open KEYS,'<keys' or die $!;
	open VALUES,'<values' or die $!;
	
	while(my $key = <KEYS>){
		my $value = <VALUES>;
		chomp($key, $value);
		if(!exists($data{$key})){
			$data{$key} = $value;
		}
	}
	return \%data;
}
