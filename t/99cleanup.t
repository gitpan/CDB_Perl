use Test::More tests => 1;

ok(cleanup(),'Cleaning up temporary files');

sub cleanup{
#try and cleanup after ourselfs
	chdir('tmp');
	my $ret = unlink((qw(keys values write.cdb write_tie.cdb)));
	chdir('..');
	$ret &&= rmdir('tmp');
	return $ret;
}

