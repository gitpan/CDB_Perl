use Test::More tests => 1;

ok(cleanup(),'Cleaning up temporary files');

sub cleanup{
#try and cleanup after ourselfs
	chdir('tmp');
	unlink($_) for (qw(keys values write.cdb write_tie.cdb));
	chdir('..');
	rmdir('tmp');
}

