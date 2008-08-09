package CDB_Perl;

$VERSION = '0.53';

use strict;
use warnings;

sub seek{
	my ($self,$pos, $where) = @_;
	$where ||= 0;
	seek($self->file, $pos, $where) or die "Error seeking file";
	$self->pos($pos);
}

sub hash {
	my $s = $_[1];

	if (!defined($s)) {
		die "Can't hash an undefined value\n";
	}
	my $h = 5381;
	{

		#ugly kludge
		use integer;
		for my $c (unpack("C*",$s)) {
			$h = $h + ($h << 5);
			$h = $h ^ $c;
			$h = $h & 0xffffffff; 
		}
	}
	if($h<0){
		#another ugly kludge
		$h = (($h>>1)<<1) + ($h & 1);
	}
	return ($h, $h&255, $h>>8);
}

sub set{
	my ($self,$method,$value) = @_;

	if(defined $value){
		$self->{$method} = $value;
		return $self;
	}else{
		return $self->{$method};
	}
}

sub file{
	shift->set('file',@_);
}

sub pos{
	shift->set('pos',@_);
}

1;

=encoding utf8

=head1 NAME

CDB_Perl - Perl extension for reading and creating CDB files

=head1 SYNOPSIS

	###################
	#### Read a CDB ###
	###################

	require CDB_Perl::Read;
	my $rcdb = CDB_Perl::Read->new('file.cdb');

	#get all values associated with a key 'key'
	my @values = $rcdb->get_values('key');

	#get the first value (insertion order)
	my $value = $rcdb->get_value('key');
	@values = $rcdb->get_value('key');

	#get the next values, end indicated by undef
	#use when iterating over multiple values of a key
	my $next_value = $rcdb->get_next();

	####################
	### Create a CDB ###
	####################

	require CDB_Perl::Write;
	my $wcdb = CDB_Perl::Write->new('create.cdb');

	#insert key value pairs
	$wcdb->insert('key','value');

	#finish the CDB (automatic in destructor so you don't need to do this)
	$wcdb->finish;

	#####################
	### tie interface ###
	#####################

	### Reading

	my %read;
	tie %read, 'CDB_Perl::Read', 'read.cdb';

	#read a key value
	my $val = $read{'key'};	# only first key by insertion order

	#iterate through a CDB (all key/value pairs by insertion order, even multiple ones
	while(my($k,$v) = each(%read)){
		#do something
	}

	### Creating

	my %write;
	tie %write, 'CDB_Perl::Write', 'write.cdb';

	#store a key/value pair
	$write{'key'} = 'value';

	#write all data, no need to call this, destructor takes care of that
	untie %data;


=head1 DESCRIPTION

B<CDB_Perl> is a B<perl only> interface to read and create CDB files.
CDB stands for Constant Database, a data format created by Dan Berstein.

It's very efficient to read CDB files but creation is somewhat costly.
This module is a fall-back option for people with problems using XS modules. See next section for better alternatives.

=head1 SEE ALSO

L<CDB_File|CDB_File> XS implementation quite faster than this module

The eg directory for some examples on how to use the package

=head1 TO DO

Improve documentation a lot

=head1 AUTHOR

Cláudio Valente, E<lt>plank@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2008 by Cláudio Valente

This library is free software; you can redistribute it and/or modify it under the same terms as Perl itself. 

=cut
