# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use File::Compare qw(compare);

use Test::More tests => 7;
use bytes;
use strict;

BEGIN { use_ok('CDB_Perl::Write') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

chdir('tmp') or die "Could not change current directory. $!\n";

ok(tie(my %cdb, 'CDB_Perl::Write', 'write_tie.cdb'), 'Create tied hash');
ok(!($cdb{'#CDB'} = '#Perl'), 'Insert one entry');

sub insert_values{
	open KEYS,'<','keys' or die;
	open VALUES,'<','values' or die;
	
	while(my $key = <KEYS>){
		my $value = <VALUES>;
		chomp($key, $value);
		if ($cdb{$key} = $value){
			return;
		}
	}
	return 1;
}

ok(insert_values(),'Insert random data');
ok(untie %cdb,'Untie cdb');
ok(-s 'write.cdb' == -s 'write_tie.cdb','File sizes match');
ok(0==compare('write.cdb', 'write_tie.cdb'),'Compare tied and not tied cdbs');
