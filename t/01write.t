# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

use Test::More tests => 5;
BEGIN { use_ok('CDB_Perl::Write') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

use strict;

if(! -d 'tmp'){
	mkdir('tmp') or die "Error creating tmp directory to make tests. $!\n";
}
chdir('tmp') or die "Could not change current directory. $!\n";

#first create a random list with repeated entries

our $cdb;
ok($cdb = CDB_Perl::Write->new('write.cdb'), 'Create writer object');
ok($cdb->insert('#CDB','#Perl'),'Insert entry');

our $len = 10000;
our @vocab = ('a'..'z','A'..'Z',0..9);

sub insert_values {

	open KEYS,   '>:raw', 'keys' or die;
	open VALUES, '>:raw', 'values' or die;

	for (0 .. $len) {
		my $key   = randword();
		my $value = randword();
		print KEYS $key . "\n";
		print VALUES $value . "\n";
		$cdb->insert($key, $value);
	}

	close(KEYS) or die;
	close(VALUES) or die;
}

sub randword{
	my $len = shift || 20;
	my $word = '';
	for(1..(int rand($len)+1)){
		$word .= $vocab[int rand(@vocab)];
	}
	return $word;
}

ok(insert_values(),'Save random data on CDB');
ok($cdb->finish,'Finalize');