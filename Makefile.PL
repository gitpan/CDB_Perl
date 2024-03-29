use 5;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'CDB_Perl',
    'VERSION_FROM'	=> 'lib/CDB_Perl.pm', # finds $VERSION
    'PREREQ_PM'		=> {'Test::More' => 0}, # e.g., Module::Name => 1.1
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT => 'Read and create CDB files in pure perl (no xs)', # retrieve abstract from module
       AUTHOR     => 'Cláudio Valente <plank@cpan.org>') : ()),
);
