use Test::More tests => 1;
use File::Spec::Functions;

ok(cleanup(),'Cleaning up temporary files');

sub cleanup{
#try and cleanup after ourselfs
	my $status=1;
	chdir(catfile('tmp'));
	for (qw(keys values write.cdb write_tie.cdb)){
		$status &&= unlink($_);
	}
	chdir('..');
	$status &&=rmdir('tmp');
	return $status;
}

