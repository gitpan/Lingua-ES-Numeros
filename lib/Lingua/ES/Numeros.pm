=head1 NAME

Lingua::ES::Numeros - Translates numbers to spanish text

=head1 SYNOPSIS

   use Lingua::ES::Numeros

   $obj = new Lingua::ES::Numeros ('MAYUSCULAS' => 1)
   print $obj->Cardinal(124856), "\n";
   print $obj->Real(124856.531), "\n";
   $obj->{GENERO} = 'a';
   print $obj->Ordinal(124856), "\n";

=head1 REQUIERE

Perl 5.006, Exporter, Carp

=head1 DESCRIPTION

Lingua::ES::Numeros converts arbitrary numbers into human-oriented Spanish text.

This module supports the translation of cardinal, ordinal and, real numbers, the
module handles integer numbers up to vigintillions (that's 1e120), since Perl
does not handle such numbers natively, numbers are kept as text strings because
processing does not justify using bigint.

=cut

#######################################################################
# Jose Luis Rey Barreira (C) 2001-2007
# Under GPL license [ http://www.gnu.org ]
#######################################################################

package Lingua::ES::Numeros;

use 5.006;
use utf8;
use strict;
use warnings;

use Carp;

our @ISA = qw();

our $VERSION = '0.02';

use fields qw/ ACENTOS MAYUSCULAS UNMIL HTML DECIMAL SEPARADORES GENERO
                POSITIVO NEGATIVO FORMATO /;

=head1 METHODS

=head2 $obj = Lingua::ES::Numeros->new(%options)

Creates a new translation object. Options mey be a list of the
following KEY => VALUE pairs:

=over 4

=item DECIMAL

Decimal point delimiter, a single character used to delimit integer 
and fraction parts of the number. Default value is ".".

=item SEPARADORES

Delimiters ignored while parsing numbers. Characters in this set are
deleted before number parsing, by default SEPARADORES is the following
string: '_'

=item ACENTOS

If ACENTOS is true then number names will be ortographically correct
with accent characters included, otherwise accented letters will be 
translated to USACII characters. This is true by default.

=item MAYUSCULAS

Numbers are translated to all uppercase if this is true, otherwise the
text will be all lowercase which is the default.

=item HTML

Returns HTML text (normal text with HTML entities) if true, defaults to
false.

=item GENERO

Sets the gender of the numbers, it may have the folowing values:
  'a'   female gender
  'o'   male gender
  ''    no gender (neutral gender)

The following table shows the efect of gender on Cardinal and
Ordinal numbers:

 +---+--------------------+-----------------------------+
 |N  |     CARDINAL       |          ORDINAL            |
 |u  +------+------+------+---------+---------+---------+
 |m  | 'o'  | 'a'  |  ''  |   'o'   |   'a'   |   ''    |
 +---+------+------+------+---------+---------+---------+
 | 1 | uno  | una  | un   | primero | primera | primer  |
 | 2 | dos  | dos  | dos  | segundo | segunda | segundo |
 | 3 | tres | tres | tres | tercero | tercera | tercer  |
 +---+------+------+------+---------+---------+---------+

=item UNMIL

If true (the defaut), 1000 will be translated "un mil", otherwise it
will be translated to the more informal "mil".

=item NEGATIVO

Label for negative numbers, this is prepended to negative numbers,
default value is "menos". For example: translation of -5 will yield
"menos cinco".

=item POSITIVO

Label for positive numbers, this is prepended to positive numbers,
default value is "" (blank). For example: translation of 5 will yield
"cinco".

=item FORMATO

String for formatting of real numbers, default value is:
  'con %2d ctms.'
(see B<real>).

This is DEPRECATED.

=back

=cut

my %new_defaults = (
    ACENTOS     => 1,
    MAYUSCULAS  => 0,
    UNMIL       => 1,
    HTML        => 0,
    DECIMAL     => '.',
    SEPARADORES => '_',
    GENERO      => 'o',
    POSITIVO    => '',
    NEGATIVO    => 'menos',
    FORMATO     => 'con %02d ctms.', );


sub new {
    my $self = shift;
    unless (ref $self) {
        $self = fields::new( $self );
    }
    #%$self = (%new_defaults, @_);
    {   # Compatibility conversion of SEXO into GENERO
        my %opts = (%new_defaults, @_);
        if ( $opts{'SEXO'} ) {
            $opts{'GENERO'} = $opts{'SEXO'};
            delete $opts{'SEXO'} }
        %$self = %opts
    }
    return $self;
}

=head2 $text = $obj->cardinal($num)

Translates a cardinal number ($num) to spanish text, translation
is performed according to the following object ($obj) settings:
DECIMAL, SEPARADORES, SEXO, ACENTOS, MAYUSCULAS, POSITIVO and
NEGATIVO.

This method ignores any fraction part of the number ($num).

=cut


sub cardinal($) {
	my $self = shift;
    my $num = shift;
	my ($sgn, $ent, $frc, $exp)= parse_num($num, $self->{'DECIMAL'}, $self->{'SEPARADORES'});
    my @words = cardinal_simple($ent, $exp, $self->{'UNMIL'}, $self->{'GENERO'});
    if ( @words ) {
        unshift @words, $self->{'NEGATIVO'} if $sgn < 0 and $self->{'NEGATIVO'};
        unshift @words, $self->{'POSITIVO'} if $sgn > 0 and $self->{'POSITIVO'};
        $self->retval( join(" ", @words) ) }
    else {
        $self->retval( 'cero' ) }
}


=head2 $text = real($n; $genf, $genm)

Translates the real number ($n) to spanish text.

The optional $genf and $genm parameters are used to specify gender of the
fraction part and fraction part magnitude in that order.  If $genf is missing
it will default to the GENDER option, and $genm will default to the $genf's
value.

This translation is affected by the options: DECIMAL, SEPARADORES, GENDER, 
ACENTOS, MAYUSCULAS, POSITIVO, NEGATIVO and FORMATO.

=head3 Fraction format (FORMATO)

WARNING ** WARNING ** WARNING ** WARNING

   THE FORMATO OPTION IS DEPRECATED

WARNING ** WARNING ** WARNING ** WARNING

FORMAT option is a formatting string like printf, it is used to format the
fractional part before appending it to the integer part. It has the following
format specifiers:

=over 4

=item %Ns

Formats the fractional part as text with precisión of N digits, for example:
number '124.345' formated with string 'CON %s.' will yield the text 'ciento
veinticuatro CON trescientas cuarenta y cinco milE<eacute>simas', and
formatted with string 'CON %2s.' will yield 'ciento veinticuatro CON treinta
y cuatro centE<eacute>simas'.

=item %Nd

Formats the fractional part as a number (no translation), with precision
of N digits, veri similar to sprintf's %d format, for example: number 
'124.045' formated with 'CON %2d ctms.' will yield: 'ciento veinticuatro
CON 04 ctms.'

=back

=cut

sub real($;$$) {
	my $self = shift;
    my ($num, $genf, $genm) = @_;
	my ($sgn, $ent, $frc, $exp)= parse_num($num, $self->{'DECIMAL'}, $self->{'SEPARADORES'});
	
    my $gen = $self->{'GENERO'};
    $genf = $gen unless defined $genf;
    $genm = $genf unless defined $genm;

	# Convertir la parte entera ajustando el sexo
    #my @words = cardinal_simple($ent, $exp, $self->{'UNMIL'}, $gen);

	# Traducir la parte decimal de acuerdo al formato
	for ($self->{'FORMATO'}) {
		/%([0-9]*)s/ && do { 
			# Textual, se traduce según el genero
            $frc = substr('0' x $exp . $frc, 0, $1) if $1;
            $frc = join(" ", fraccion_simple($frc, $exp, $self->{'UNMIL'}, $genf, $genm));
			$frc = $frc ? sprintf($self->{'FORMATO'}, $frc) : '';
			last };
		/%([0-9]*)d/ && do {
			# Numérico, se da formato a los dígitos
			$frc = substr('0' x $exp . $frc, 0, $1);
			$frc = sprintf($self->{'FORMATO'}, $frc);
			last };
		do {
			# Sin formato, se ignoran los decimales
			$frc = ''; 
			last }; }
	if ($ent) {
        $ent = $self->cardinal( ($sgn < 0 ? '-' : '+') . $ent) } 
	else {
		$ent = 'cero' }
	$ent .= ' ' . $frc if $ent and $frc;
	return $self->retval($ent);
}

=item $n = ordinal($n)

Convierte el número $n, como un número ordinal a castellano.  

La conversión esta afectada por los campos: DECIMAL, SEPARADORES,
SEXO, ACENTOS y MAYUSCULAS.

Presenta advertencias si el número es negativo y/o si no es un natural >
0.

=cut

sub ordinal($) {
	my $self = shift;
    my $num = shift;
	my ($sgn, $ent, $frc, $exp)= parse_num($num, $self->{'DECIMAL'}, $self->{'SEPARADORES'});
	
	croak "Ordinal negativo" if $sgn < 0;
	carp "Ordinal con decimales" if $frc;

	if ($ent =~ /^0*$/) {
		carp "Ordinal cero";
		return '';
	}

    my $text = join(" ", ordinal_simple($ent, $exp, $self->{'GENERO'}));

	return $self->retval($text);
}


=head1 INTERNALS

Functions in this seccition are generally not used, but are docummented here for completeness

=head2 CARDINAL SUPPORT

Construction of cardinal numbers

=cut

#####################################################################
#
# Soporte para números CARDINALES
#
####################################################################

my @cardinal_30 = qw/ cero un dós tres cuatro cinco seis siete ocho nueve diez
    once doce trece catorce quince dieciséis diecisiete dieciocho diecinueve
	veinte veintiun veintidós veintitrés veinticuatro veinticinco veintiséis
    veintisiete veintiocho veintinueve /;

my @cardinal_dec = qw/
	0 1 2 treinta cuarenta cincuenta sesenta setenta ochenta noventa /;

my @cardinal_centenas = ( "", qw/
	ciento doscientos trescientos cuatrocientos quinientos
    seiscientos setecientos ochocientos novecientos / );
	
my @cardinal_megas = ( "", qw/ m b tr cuatr quint sext sept oct non dec undec
    dudec tredec cuatordec quindec sexdec sepdec octodec novendec vigint / );

my $MAX_DIGITS = 6 * @cardinal_megas;


=head3 cardinal_e2($n, $nn)

This procedure takes $n (an integer in the range [0 .. 99], not verified) and
adds the numbers text translation to $nn (a word stack), on a word by word basis.
If $n == 0 nothing is pushed into $nn.

Returns nothing.

=cut

sub cardinal_e2($$) {
    my ($n, $nn) = @_;

    return if $n == 0;
    do { push @$nn, $cardinal_30[ $n ]; return } if $n < 30;
    $n =~ /^(.)(.)$/;
    push @$nn, $cardinal_30[ $2 ], "y" if $2;
    push @$nn, $cardinal_dec[ $1 ]
}


=head3 cardinal_e3($n, $nn)

This procedure takes $n (an integer in the range [0 .. 99], not verified) and
adds the numbers text translation to $nn (a word stack), on a word by word basis.
If $n == 0 nothing is pushed into $nn.

Returns nothing.

=cut

sub cardinal_e3($$) {
    my ($n, $nn) = @_;

    return if $n == 0;
    $n == 100 and do { push @$nn, "cien"; return };
    cardinal_e2( $n % 100, $nn );
    $n >= 100 and push @$nn, $cardinal_centenas[ int( $n / 100 ) ];
}


=head3 cardinal_e6($n, $nn, $mag, $un_mil, $postfix)

Parameters:
  $n        the number between 0 and 999999 (not verified).
  $nn:      word stack.
  $mag:     magnitude of the number 1 for millions, 2 for billions,
            etc.
  $un_mil:  if true 1000 is translated as "un mil" otherwise "mil"
  $postfix: array representing plural & singular magnitude of the
            number, in this order.

This procedure takes $n, and pushes the numbers text translation into $nn,
on a word by word basis, with the proper translated magnitude.  If $n == 0
nothing is pushed into $nn.

Returns nothing.

=cut

sub cardinal_e6($$$$$) {
    my ($n, $nn, $mag, $un_mil, $postfix) = @_;

    return if $n == 0;
    push @$nn, $cardinal_megas[ $mag ] . $postfix->[$n == 1] if $mag;
    cardinal_e3($n % 1000, $nn);
	my $n3 = int($n / 1000);
    if ( $n3 ) {
        push @$nn, "mil";
        cardinal_e3($n3, $nn) if $n3 != 1 or $un_mil; }
}


=head3 cardinal_generic($n, $exp, $fmag, $gen)

Parameters:
  $n        the number.
  $exp:     exponent.
  $fmag:    closure to format the 6 digits groups.
  $gen:     gender of the number:
                'a' for female gender (1 -> una).
                'o' for male gender (1 -> uno).
                ''  for neutral gender (1 -> un).

This function translate the natural number $n to spanish words, adding 
gender where needed.

Returns the translation of $n to spanish text as a list of words.

=cut

sub cardinal_generic($$$$) {
	my ($n, $exp, $fmag, $gen) = @_;
    
	$n =~ s/^0*//;		                # eliminar ceros a la izquierda
    return () unless $n;
    croak("Fuera de rango") if length($n)+$exp > $MAX_DIGITS;
    $n .= "0" x ($exp % 6);             # agregar ceros a la derecha
    my $mag = int($exp / 6);
    my @group = ();
    $fmag->($1, \@group, $mag++) while $n =~ s/(.{1,6})$//x;
    $group[0] .= $gen if $group[0] =~ /un$/;
    reverse @group;
}


=head3 cardinal_simple($n, $exp, $un_mil; $gen)

Parameters:
  $n        the number.
  $exp:     exponent.
  $un_mil:  if true 1000 is translated as "un mil" otherwise "mil"
  $gen:     gender of the number (optional with default value ''):
                'a' for female gender (1 -> una).
                'o' for male gender (1 -> uno).
                ''  for neutral gender (1 -> un).

This function translate the natural number $n to spanish words, adding 
gender where needed.

This procedure just builds a closure with format information, to call
cardinal_e6, and then calls cardinal_generic to do the work.

Returns the translation of $n to spanish text as a list of words.

=cut

sub cardinal_simple($$$;$) {
	my ($n, $exp, $un_mil, $gen) = @_;

    $un_mil = $un_mil ? 1 : 0;
    $gen = '' unless $gen;
    my $format = sub {
        cardinal_e6($_[0], $_[1], $_[2], $un_mil, [ 'illones', 'illón' ]) };
    cardinal_generic($n, $exp, $format, $gen)
}


=head3 fraccion_mag_prefix($mag, $gp)

Parameters:
  $mag:     magnitude of the number 1 for millionths, 2 for billionths,
            etc.
  $gp:      gender and plural of the number ('as' is female plural,
            'o' is male singular), $gp=$gender . $plural

This function returns the name of the magnitude of a fraction, $mag 
is the number of decimal digits. For example 0.001 has $mag == 3 and 
translates to "milesimos" if $gp is 'os'.

Returns the translation of $n to spanish text as a string.

=cut

sub fraccion_mag_prefix($$) {
    my ($mag, $gp) = @_;

    return "" unless $mag;
    return "décim" . $gp if $mag == 1;
    return "centésim" . $gp if $mag == 2;
    my $format = sub {
        cardinal_e6($_[0], $_[1], $_[2], 0, [ 'illon', 'illon' ]) };
    my @name = cardinal_generic(1, $mag, $format, "");
    shift @name unless $mag % 6;
    join("", @name, "ésim", $gp);
}


=head3 fraccion_simple($n, $exp, $un_mil, $gen; $ngen)

Parameters:
  $n        the number.
  $exp:     exponent.
  $un_mil:  if true 1000 is translated as "un mil" otherwise "mil"
  $gen:     gender of the magnitude:
                'a' for female gender (1 -> una).
                'o' for male gender (1 -> uno).
                ''  for neutral gender (1 -> un).
  $ngen:    gender of the number (same values as $gen).

This function translate the fraction $n to spanish words, adding 
gender where needed.

This procedure just builds a closure with format information, to call
cardinal_e6, and then calls cardinal_generic to do the work.

Returns the translation of $n to spanish text as a list of words.

=cut

sub fraccion_simple($$$$;$) {
	my ($n, $exp, $un_mil, $gen, $ngen) = @_;
    
	$n =~ s/0*$//;                      # eliminar 0 a la derecha
    return () if $n == 0;
    $ngen = $gen unless defined $ngen;
	$exp = -$exp + length $n;           # adjust exponent
    croak("Fuera de rango") if $exp > $MAX_DIGITS;
    $gen .= "s" unless $n =~ /^0*1$/;
    (cardinal_simple($n, 0, $un_mil, $ngen), fraccion_mag_prefix($exp, $gen));
}


=head2 ORDINAL SUPPORT

Construction of ordinal numbers

=cut

#####################################################################
#
# Soporte para números ORDINALES
#
####################################################################

my @ordinal_13 = ( '', qw/ primer_ segund_ tercer_ cuart_ quint_ sext_
                    séptim_ octav_ noven_ décim_ undécim_ duodécim_ / );

my @ordinal_dec = qw/ 0 1 vi tri cuadra quicua sexa septua octo nona /;

my @ordinal_cen = qw/ 0 c duoc tric cuadring quing sexc septig octing noning /;


=head3 ordinal_e2($n, $nn)

This procedure takes $n (an integer in the range [0 .. 99], not verified) and
adds the numbers text translation to $nn (a word stack), on a word by word basis.
If $n == 0 nothing is pushed into $nn.

Returns nothing.

=cut

sub ordinal_e2($$) {
    my ($n, $nn) = @_;

    return if $n == 0;
    if ( $n < 13 ) {
        push @$nn, $ordinal_13[ $n ];
        return }
    $n =~ /^(.)(.)$/;
    my $lo = $ordinal_13[ $2 ];
    if ( $1 <= 2 ) {
        my $name = $2   ? ($1 == 1 ? 'decimo' : 'vigesimo')
                        : ($1 == 1 ? 'décim_' : 'vigésim_');
        $name =~ s/o$// if $2 == 8;        # special case vowels colapsed
        push @$nn, $name . $lo;
        return }
    push @$nn, $lo if $2;
    push @$nn, $ordinal_dec[ $1 ] . 'gésim_';
}


=head3 ordinal_e3($n, $nn)

This procedure takes $n (an integer in the range [0 .. 999], not verified) and
adds the numbers text translation to $nn (a word stack), on a word by word basis.
If $n == 0 nothing is pushed into $nn.

Returns nothing.

=cut

sub ordinal_e3($$) {
    my ($n, $nn) = @_;

    return if $n == 0;
    ordinal_e2($n % 100, $nn);
    push @$nn, $ordinal_cen[ int($n / 100) ] . 'entésim_' if $n > 99;
}


=head3 ordinal_e6($n, $nn, $mag, $un_mil, $postfix)

Parameters:
  $n        the number between 0 and 999999 (not verified).
  $nn:      word stack.
  $mag:     magnitude of the number 1 for millions, 2 for billions,
            etc.

This procedure takes $n, and pushes the numbers text translation into $nn,
on a word by word basis, with the proper translated magnitude.  If $n == 0
nothing is pushed into $nn.

Returns nothing.

=cut

sub ordinal_e6($$$) {
    my ($n, $nn, $mag) = @_;

    return if $n == 0;
    push @$nn, $cardinal_megas[ $mag ] . 'illonésim_' if $mag;
    ordinal_e3($n % 1000, $nn);
	my $n3 = int($n / 1000);
    if ( $n3 ) {
        if ( $n3 > 1 ) {
            my $pos = @$nn;             # keep pos to adjust number
            cardinal_e3($n3, $nn);      # this is not a typo, its cardinal
            $nn->[$pos] .= 'milésim_' }
        else {
            push @$nn, "milésim_" }}
}


=head3 ordinal_simple($n, $exp; $gen)

Parameters:
  $n        the number.
  $exp:     exponent.
  $un_mil:  if true 1000 is translated as "un mil" otherwise "mil"
  $gen:     gender of the magnitude (optional defaults to ''):
                'a' for female gender (1 -> primera).
                'o' for male gender (1 -> primero).
                ''  for neutral gender (1 -> primer).

This function translate the fraction $n to spanish words, adding 
gender where needed.

This procedure just builds a closure with format information, to call
ordinal_e6, and then calls ordinal_generic to do the work.

Returns the translation of $n to spanish text as a list of words.

=cut

sub ordinal_simple($$;$) {
	my ($n, $exp, $gen) = @_;
    
	$n =~ s/^0*//;		                # eliminar ceros a la izquierda
    return () unless $n;
    croak("Fuera de rango") if length($n)+$exp > $MAX_DIGITS;
    $n .= "0" x ($exp % 6);             # agregar ceros a la derecha
    my $mag = int($exp / 6);

    my @group = ();
    if ( $mag == 0 ) {
        $n =~ s/(.{1,6})$//x;
        ordinal_e6($1, \@group, $mag++) }

    while ( $n =~ s/(.{1,6})$//x ) {
        if ( $1 == 0 ) {
            $mag++;
            next }
        my $words = [];
        if ( $1 == 1 ) {
            push @$words, '' }
        else {
            cardinal_e6($1, $words, 0, 0, []) }
        $words->[0] .= $cardinal_megas[ $mag++ ] . 'illonésim_';
        push @group, @$words }

    unless ( $gen ) {
        $group[0] =~ s/r_$/r/;          # Ajustar neutros en 1er, 3er, etc.
        $gen = 'o' }
    s/_/$gen/g for @group;
    reverse @group;
}


=head2 MISCELANEOUS

Everithing not fitting elsewere

=cut

=head3 parse_num($num, $dec, $sep)

Parameters:
  $num:     the number.
  $dec:     decimal separator (tipically ',' or '.').
  $sep:     separator characters ignored by the parser.

This function parses a general number and returns a list of 4 
elements:
  $sgn:     sign of the number: -1 if negative, 1 otherwise
  $int:     integer part of the number
  $frc:     decimal (fraction) part of the number
  $exp:     exponent of the number

Croaks if there is a syntax error.

=cut

sub parse_num($$$) {
	my ($num, $dec, $sep) = @_;

	# Eliminar blancos y separadores
	$num =~ s/[\s\Q$sep\E]//g;
	$dec = '\\' . $dec if $dec eq '.';
	my ($sgn, $int, $frc, $exp) = $num =~ /^
        ([+-]?) (?= \d | $dec\d )   # signo
        (\d*)                       # parte entera
        (?: $dec (\d*) )?           # parte decimal
        (?: [Ee] ([+-]?\d+) )?      # exponente
        $/x or croak("Error de sintaxis");

    $sgn = $sgn eq '-' ? -1 : 1;                # ajustar signo
    return ($sgn, $int || 0, $frc || 0, $exp) unless $exp ||= 0;

    $int ||= '';
    $frc ||= '';

	# reducir la magnitud del exponente
	if ($exp > 0) {
		if ($exp > length $frc) {
			$exp -= length $frc;
			$int .= $frc;
			$frc = '' }
		else {
			$int .= substr($frc, 0, $exp);
			$frc = substr($frc, $exp);
			$exp = 0 }}
	else {
		if (-$exp > length $int) {
			$exp += length $int;
			$frc = $int . $frc;
			$int = '' }
		else {
			$frc = substr($int, $exp + length $int) . $frc;
			$int = substr($int, 0, $exp + length $int);
			$exp = 0 }}
	return ($sgn, $int || 0, $frc || 0, $exp);
}


=head3 $obj->retval($value)

Utility method to adjust return values, transforms text 
following the options: ACENTOS, MAYUSCULAS y HTML.

Returns the adjusted $value.

=cut

sub retval($$)
{
	my $self = shift;
    my $rv = shift;
	if ($self->{ACENTOS}) {
		if ( $self->{HTML} ) {
			$rv =~ s/([áéíóú])/&$1acute;/g;
			$rv =~ tr/áéíóú/aeiou/; } } 
	else {
		$rv =~ tr/áéíóú/aeiou/ }
	return $self->{MAYUSCULAS} ? uc $rv : $rv;
}


# Preloaded methods go here.

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 SEE ALSO

http://roble.pntic.mec.es/~msanto1/ortografia/numeros.htm

=head1 AUTHOR

Jose Rey, E<lt>jrey@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2001-2007 by Jose Rey

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
