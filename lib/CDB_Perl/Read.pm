package CDB_Perl::Read;

use Carp qw(carp croak);

require CDB_Perl;
@ISA = qw(CDB_Perl);

use strict;

sub new{
	my ($pack, $fname, $cache) = @_;

	if(!$pack or ref($pack)){
		croak "Invalid constructor parameter";
	}
	
	if(!defined($fname)){
		croak "file parameter mandatory at $pack->new(file)";
	}

	#by default cache is on
	if(!defined($cache)){
		$cache = 1;
	}
	if(!-e $fname){
		croak "$fname doesn't exist";
	}
	if(!-r $fname){
		croak "$fname isn't readable";
	}
	my $size = -s $fname;
	if($size < 2048){
		croak "invalid file (< 2048 bytes)";
	}
	my $file;
	open $file,'<:raw',$fname or croak "Error opening file $fname. $!";

	my $self = bless {},$pack;
	$self->file($file)->cache($cache)->fsize($size);

	if($cache){
		$self->tables({});
	}
	return $self;
}

sub get_value{
	if(wantarray){
		return &get_values(@_);
	}
	my ($self, $key) = @_;

	if(!defined($key)){
		croak "key must be defined";
	}

	my($h,$h0,$h1) = $self->hash($key);
	
	my $iter = {
		key  => $key,
		hash => $h,
		tnum => $h0,
		pos  => $h1,
	};

	$self->iter($iter);
	return $self->get_next;
}

sub get_values{
	my $self = shift;
	my $val = $self->get_value(@_);
	my @rsp = ();

	if(defined($val)){
		@rsp = ($val);
		while(defined($val = $self->get_next)){
			push @rsp,$val;
		}
	}
	return @rsp;
}

sub get_next{
	my $self = shift;

	my $iter = $self->iter;
	if(!$iter){
		croak "Can't call get_next without having called get_value";
	}

	my $table = $self->get_table($iter->{'tnum'});
	my $len = @$table/2;
	if(!$len){
		return;
	}

	#now iterate
	for(;;){
		$iter->{'pos'} %= $len;
		my($hash,$pos) = (
			$table->[2*$iter->{'pos'}] ,
			$table->[2*++$iter->{pos} -1]
		);

		if($pos == 0){
			return;
		}
		if($hash == $iter->{'hash'}){
			my ($key, $val) = $self->entry($pos);
			if ($key eq $iter->{'key'}){
				return $val;
			}
		}
	}
}

sub get_table{
	my ($self, $n) = @_;

	if(!defined($n)){
		die "table number not defined";
	}

	my $cache = $self->cache;

	if($cache && (exists($self->tables->{$n}))){
		return $self->tables->{$n};
	}

	#position in the header
	$self->seek(8*$n);
	my($pos,$len) = $self->read_long(2);

	$self->seek($pos);
	my @table = $self->read_long(2*$len);

	if($cache){
		$self->tables->{$n} = \@table;
	}

	return \@table;
}

sub entry{
	my ($self, $pos) = @_;

	if($pos < 2048){
		die "pos $pos is invalid";
	}

	$self->seek($pos);
	my ($klen, $vlen) = $self->read_long(2);
	return ((map{$self->read($_)}($klen,$vlen)), $klen, $vlen);
}

sub read{
	my ($self, $len) = @_;

	if(!defined($len)){
		die "Can't read an undefined number of characters.";
	}

	my $data;
	read($self->file,$data,$len) or die "Error reading file";
	#pos not updated
	return $data;
}

sub read_long{
	my ($self, $len) = @_;
	
	if($len == 0){
		return ();
	}

	my @rsp = unpack("V$len",$self->read($len*4));
	return @rsp;
}

sub cache{
	shift->set('cache',@_);
}

sub fsize{
	shift->set('fsize',@_);
}

sub iter{
	shift->set('iter',@_);
}

sub tables{
	shift->set('tables',@_);
}

#Tied hash interface follows

sub TIEHASH{
	my $pack = shift;
	return $pack->new(@_);
}

sub FETCH{
	my ($self, $key) = @_;

	my $lkey = $self->{'tie'}->{'lastkey'};
	if(defined($lkey) && $key eq $lkey){
		return $self->{'tie'}->{'lastvalue'};
	}

	my $value = $self->get_value($key);
	$self->{'tie'}->{'lastkey'} = $key;
	$self->{'tie'}->{'lastvalue'} = $value;

	return $value;
}

sub STORE{
	croak "Can't store data on a readonly CDB";
}

sub EXISTS{
	my ($self, $key) = @_;

	return defined($self->get_value($key));
}

sub FIRSTKEY{
	my $self = shift;
	$self->{'tie'}->{'iterate_pos'} = 2048;
	#this could break on 'weird' CDB files
	$self->seek(0);
	$self->{'tie'}->{'max_pos'} = ($self->read_long(1))[0];

	delete($self->{'tie'}->{'lastkey'});
	delete($self->{'tie'}->{'lastvalue'});

	return $self->NEXTKEY;
}

sub NEXTKEY{
	my $self = shift;
	#don't need the previous key

	my $pos = \$self->{'tie'}->{'iterate_pos'};
	return unless $$pos < $self->{'tie'}->{'max_pos'};

	my ($key,$val, $klen, $vlen) = $self->entry($$pos);
	$$pos += $klen + $vlen + 8;

	$self->{'tie'}->{'lastkey'} = $key;
	$self->{'tie'}->{'lastvalue'} = $val;

	return $key;
}

sub DELETE{
	croak "Can't delete data on a readonly CDB";
}
*CLEAR = \&DELETE;

1;
