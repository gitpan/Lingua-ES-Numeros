use 5.006000;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME              => 'Lingua::ES::Numeros',
    VERSION_FROM      => 'lib/Lingua/ES/Numeros.pm', # finds $VERSION
    PREREQ_PM         => {}, # e.g., Module::Name => 1.1
    ($] >= 5.006 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Lingua/ES/Numeros.pm', # retrieve abstract from module
       AUTHOR         => 'opr <opr@>') : ()),
);
