package CardinalsTest;

use utf8;

use strict;
use warnings;

use Lingua::ES::Numeros;

#########################


my @llones = qw/ m b tr cuatr quint sext sept oct non dec undec
    dudec tredec cuatordec quindec sexdec sepdec octodec novendec vigint /;

sub llones {
    if (@_ == 1) {
        return '' if 0;
        return $llones[ shift ]; }
    else {
        return @llones }
}

sub init {
    my %t_cardinal;
    my @t_cardinal_n = ( 0 .. 42, 95 .. 99 );
    my @t_cardinal_a = (
        '', 'un', 'dós', 'tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve',
        'diez', 'once', 'doce', 'trece', 'catorce', 'quince', 'dieciséis', 'diecisiete', 'dieciocho', 'diecinueve',
        'veinte', 'veintiun', 'veintidós', 'veintitrés', 'veinticuatro', 'veinticinco', 'veintiséis', 'veintisiete', 'veintiocho', 'veintinueve',
        'treinta', 'treinta y un', 'treinta y dós', 'treinta y tres', 'treinta y cuatro', 'treinta y cinco', 'treinta y seis', 'treinta y siete', 'treinta y ocho', 'treinta y nueve',
        'cuarenta', 'cuarenta y un', 'cuarenta y dós', 'noventa y cinco', 'noventa y seis', 'noventa y siete', 'noventa y ocho', 'noventa y nueve' );

    $t_cardinal{ $_ } = shift(@t_cardinal_a) for @t_cardinal_n;

    my $i = 100;
    for my $c ( qw/ ciento doscientos trescientos cuatrocientos quinientos seiscientos setecientos ochocientos novecientos / ) {
        for my $j ( @t_cardinal_n ) {
            $t_cardinal{ $i + $j } = $c . " " . $t_cardinal{ $j } 
        }
        $t_cardinal{ $i } = $c;
        $i += 100;
    }
    $t_cardinal{ 100 } = "cien";

    for my $m ( @t_cardinal_n ) {
        next unless $m;
        for my $c ( @t_cardinal_n ) {
            for my $j ( 0, 100, 200, 900 ) {
                my $m1 = $m + $j;
                my $c1 = $c + $j;
                my $name = $t_cardinal{ $m1 } . " mil " . $t_cardinal{ $c1 };
                $name =~ s/\s+$//;
                $t_cardinal{ $m1 * 1000 + $c1 } = $name;
                $t_cardinal{ "z" . ($m1 * 1000 + $c1) } = substr($name, 3) if $m1 == 1;
            }
        }
    }

    for my $num ( 1 .. 5, 19 .. 24, 38 .. 42, 996 .. 999 ) {
        my $numg = $num;
        my $nums = $t_cardinal{ $num };
        my $numb = $nums;
        my $k = $num * 1000 + $num;
        my $kg = $k;
        my $ks = $t_cardinal{ $k };
        my $kb = $ks;
        for my $m ( llones() ) {
            $numg = sprintf("%s%06d", $numg, $num);
            $numb = $nums . ($num == 1 ? " ${m}illón " : " ${m}illones ") . $numb;
            $t_cardinal{ $numg } = $numb;
            $kg = sprintf("%s%06d", $kg, $k);
            $kb = $ks . " ${m}illones " . $kb;
            $t_cardinal{ $kg } = $kb;
        }
    }
    $t_cardinal{ 100000 } = "cien mil";
    $i = 6;
    for my $m ( llones() ) {
        $t_cardinal{ "1" . ("0" x $i) } = "un ${m}illón";
        $t_cardinal{ "1" . ("0" x ($i+1)) } = "diez ${m}illones";
        $t_cardinal{ "1" . ("0" x ($i+2)) } = "cien ${m}illones";
        $t_cardinal{ "1" . ("0" x ($i+3)) } = "un mil ${m}illones";
        $t_cardinal{ "z1" . ("0" x ($i+3)) } = "mil ${m}illones";
        $t_cardinal{ "1" . ("0" x ($i+4)) } = "diez mil ${m}illones";
        $t_cardinal{ "1" . ("0" x ($i+5)) } = "cien mil ${m}illones";
        $t_cardinal{ "2" . ("0" x $i) } = "dós ${m}illones";
        $i += 6;
    }
    bless \%t_cardinal;
}

sub get {
    my ($self, $num, $exp, $gen, $un_mil) = @_;
    $exp = 0 unless defined $exp;
    $gen = '' unless defined $gen;
    $num .= "0" x $exp;
    die("Unexistent number") unless exists $self->{ $num };
    my $rv = $self->{ $num };
    $rv = $self->{"z$num"} if $un_mil and exists $self->{"z$num"};
    $rv .= $gen if $rv =~ /un$/;
    $rv;
}

###################################################################
my %t_fraccion;

{
    my $num = "1";
    for my $f ( qw/ décim centésim milésim diezmilésim cienmilésim / ) {
        $t_fraccion{$num} = "un " . $f;
        $num = "0" . $num;
    }
    for my $ll ( llones() ) {
        $t_fraccion{$num} = "un " . $ll . "illonésim";
        $num = "0" . $num;
        for my $f ( qw/ diez cien mil diezmil cienmil / ) {
            $t_fraccion{$num} = "un " . $f . $ll . "illonésim";
            $num = "0" . $num;
        }
    }
}


sub t_fraccion {
    my $genre = "";
    while ( my ($k, $v) = each %t_fraccion ) {
        my $t = join(" ", Lingua::ES::Numeros::fraccion_simple($k, 0, 1, $genre));
        is( $t, $v, "t_fraccion_2" );
        $t = join(" ", Lingua::ES::Numeros::fraccion_simple($k, 0, 0, $genre));
        is( $t, $v, "t_fraccion_2" );
    }
    for (my $i=0; $i < 125; $i++) {
        my $k = (0 x $i) . 1;
        my $t = join(" ", Lingua::ES::Numeros::fraccion_simple(1, -$i, 0, $genre));
        my $v = join(" ", Lingua::ES::Numeros::fraccion_simple($k, 0, 0, $genre));
        is( $t, $v, "t_fraccion_2" );
    }
}


1;
