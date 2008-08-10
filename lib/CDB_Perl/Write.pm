package CDB_Perl::Write;

use Carp qw(carp croak);

require CDB_Perl;
@ISA = qw(CDB_Perl);

use strict;
#use warnings;

sub new{
	my $pack = shift;
	my $fname = shift or croak "$pack->new(filename); filename not defined";

	my $self =  bless{}, $pack;
	$self->file_open($fname, '>');
	$self->table([]);
	$self->seek(2048);
	return $self;
}

sub insert{
	my ($self, $k,$v) = @_;
	my $table = $self->table;
	my $pos = $self->pos;

	if(!defined($k)){
		croak "insert must be called with 'key', 'value' as arguments. Key not defined.";
	}
	my $klen = length($k);
	my $vlen = length($v);
	my ($h, $h0,$h1) = $self->hash($k);

	if(!$table->[$h0]){
		$table->[$h0] = [];
	}

	push @{$table->[$h0]},($h,$pos);

	$self->write_long($klen,$vlen);
	$self->write($k.$v,$klen+$vlen);

	return $self;
}

sub finish{
	my $self = shift;
	my $table = $self->table;
	my $pos = $self->pos;
	my $init = $pos;

	my @head;

	for my $n (0..255){
		my $t = $table->[$n];
		my $len = 0;
		if($t && @$t){
			$len = @$t;
			$pos = $self->pos;
			$self->write_table($n);
		}
		push @head,($pos,$len);
	}
	$self->seek(0);
	$self->write_long(@head);
	$self->seek($init);
	return $self;
}

sub write_table{
	my ($self, $n) = @_;
	die unless defined($n);

	my $table = $self->table->[$n];
	my $len = @$table;
	
	my @tmp;
	#init table
	$#tmp = $len*2-1;
	for(0 .. $len*2-1){
		$tmp[$_] = 0;
	}

	for my $i (0..$len/2-1){
		my $hash = $table->[$i*2];
		my $pos  = $table->[$i*2 + 1];
		
		my $h = ($hash>>8) % $len;

		#find next free slot;
		my $ii= $h*2;
		while($tmp[$ii+1] != 0){
			$ii = ($ii + 2) % (2*$len);
		}
		@tmp[$ii,$ii+1] = ($hash,$pos);
	}
	
	$self->write_long(@tmp);
	return $self;
}

*table = CDB_Perl::set('table');
*pos   = CDB_Perl::set('pos');

sub write_long{
	my $self = shift;
	my @data = @_;

	my $t = pack("V".(scalar @data),@data);
	$self->write($t,4*@data);
	return $self;
}

sub write{
	my $self = shift;
	my($data, $len) = @_;

	my $file = $self->file;
	if(!print $file $data){
		$self->io_error();
	}

	if(!defined ($len)){
		$len = length($data);
	}
	$self->pos($self->pos + $len);
	return $self;
}

sub TIEHASH{
	my $pack = shift;
	return $pack->new(@_);
}

sub FETCH{
	my ($self, $key) = @_;
	return;
	croak "Can't read data on an CDB writer $key";
}

sub STORE{
	my ($self, $key, $value) = @_;
	return $self->insert($key, $value);
}

sub UNTIE{
	shift->finish;
}

sub DELETE{
	croak "Can't remove values once inserted";
}

sub DESTROY{
	my $self = shift;
	$self->finish;
	close($self->file) or croak "Error closing CDB file.\n$!";
}

1;
