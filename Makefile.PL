use ExtUtils::MakeMaker;
BEGIN { require 5.0 }

WriteMakefile(
	'NAME'		=> 'Lingua::ES::Numeros',
	'VERSION_FROM'	=> "Numeros.pm",
	'ABSTRACT'	=> 'Convierte números cardinales en texto castellano',
	'AUTHOR'	=> 'Jose Rey (jrey@mercared.com)',
	'PM'		=> {
		'Numeros.pm' => '${INST_LIBDIR}/Numeros.pm'
		}
);
