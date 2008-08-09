use Test::More tests => 4;
BEGIN { use_ok('CDB_Perl::Read') };
use bytes;
use strict;

chdir('tmp') or die "Could not change current directory. $!\n";

ok(my $cdb = CDB_Perl::Read->new('write.cdb'), 'Create reader object');
ok(eq_array([$cdb->get_values('#CDB')], ['#Perl']),'Reading single value');
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
		my @v = $cdb->get_values($k);

		if(@v == @$v){
			for(my $n=0; $n<@v; ++$n){
				if( $v[$n] ne $v->[$n]){
					return;
				}
			}
		}else{
			return;
		}
	}
	return 1;
}
