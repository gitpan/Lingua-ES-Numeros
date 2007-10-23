package OrdinalsTest;

use utf8;

use strict;
use warnings;

use Lingua::ES::Numeros;
#use CardinalsTest;
require "t/CardinalsTest.pm";

#########################


sub init {
    my $self = shift;
    my $cardinal = shift;
    my %t_ordinal;
    my @t_ordinal_n = ( 0 .. 42, 95 .. 99 );
    my @t_ordinal_a = (
        '', 'primer_', 'segund_', 'tercer_', 'cuart_', 'quint_', 'sext_', 'séptim_', 'octav_', 'noven_',
        'décim_', 'undécim_', 'duodécim_', 'decimotercer_', 'decimocuart_', 'decimoquint_', 'decimosext_',
        'decimoséptim_', 'decimoctav_', 'decimonoven_', 'vigésim_', 'vigesimoprimer_', 'vigesimosegund_',
        'vigesimotercer_', 'vigesimocuart_', 'vigesimoquint_', 'vigesimosext_', 'vigesimoséptim_',
        'vigesimoctav_', 'vigesimonoven_', 'trigésim_', 'trigésim_ primer_', 'trigésim_ segund_',
        'trigésim_ tercer_', 'trigésim_ cuart_', 'trigésim_ quint_', 'trigésim_ sext_', 'trigésim_ séptim_',
        'trigésim_ octav_', 'trigésim_ noven_', 'cuadragésim_', 'cuadragésim_ primer_', 'cuadragésim_ segund_',
        'nonagésim_ quint_', 'nonagésim_ sext_', 'nonagésim_ séptim_', 'nonagésim_ octav_', 'nonagésim_ noven_' );

    $t_ordinal{ $_ } = shift(@t_ordinal_a) for @t_ordinal_n;

    my $i = 100;
    for my $c ( qw/ c duoc tric cuadring quing sexc septig octing noning / ) {
        for my $j ( @t_ordinal_n ) {
            $t_ordinal{ $i + $j } = $c . "entésim_ " . $t_ordinal{ $j } 
        }
        $t_ordinal{ $i } = $c . "entésim_";
        $i += 100;
    }

    for my $m ( @t_ordinal_n ) {
        next unless $m;
        for my $c ( @t_ordinal_n ) {
            for my $j ( 0, 100, 200, 900 ) {
                my $m1 = $m + $j;
                my $c1 = $c + $j;
                my $name = ($m1==1 ? '' : $cardinal->get( $m1 )) . "milésim_ " . $t_ordinal{ $c1 };
                $name =~ s/\s+$//;
                $t_ordinal{ $m1 * 1000 + $c1 } = $name;
            }
        }
    }

    for my $num ( 1 .. 5, 19 .. 24, 38 .. 42, 996 .. 999 ) {
        my $numg = $num;
        my $nums = ($num == 1 ? '' : $cardinal->get( $num ));
        my $numb = $t_ordinal{ $num };
        my $k = $num * 1000 + $num;
        my $kg = $k;
        my $ks = $cardinal->get( $k );
        my $kb = $t_ordinal{ $k };
        $ks =~ s/^un mil\b/mil/;
        for my $m ( CardinalsTest::llones() ) {
            $numg = sprintf("%s%06d", $numg, $num);
            $numb = $nums . "${m}illonésim_ " . $numb;
            $t_ordinal{ $numg } = $numb;
            $kg = sprintf("%s%06d", $kg, $k);
            $kb = $ks . "${m}illonésim_ " . $kb;
            $t_ordinal{ $kg } = $kb;
        }
    }
    $t_ordinal{ 100000 } = "cienmilésim_";
    $i = 6;
    for my $m ( CardinalsTest::llones() ) {
        $t_ordinal{ "1" . ("0" x $i) } = "${m}illonésim_";
        $t_ordinal{ "1" . ("0" x ($i+1)) } = "diez${m}illonésim_";
        $t_ordinal{ "1" . ("0" x ($i+2)) } = "cien${m}illonésim_";
        $t_ordinal{ "1" . ("0" x ($i+3)) } = "mil${m}illonésim_";
        $t_ordinal{ "1" . ("0" x ($i+4)) } = "diez mil${m}illonésim_";
        $t_ordinal{ "1" . ("0" x ($i+5)) } = "cien mil${m}illonésim_";

        # FIXME: should have only one accent
        $t_ordinal{ "2" . ("0" x $i) } = "dós${m}illonésim_";
        $i += 6;
    }
    bless \%t_ordinal, ref $self || $self;
}


sub get {
    my ($self, $num, $exp, $gen) = @_;
    $exp = 0 unless defined $exp;
    $gen = 'o' unless defined $gen;
    $num .= "0" x $exp;
    die("Unexistent number") unless exists $self->{ $num };
    my $rv = $self->{ $num };
    $rv =~ s/_/$gen/g;
    $rv;
}

1;
