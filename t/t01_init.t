# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Lingua-ES-Numbers.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use utf8;
use strict;
use warnings;

use Test::More tests => 37;
BEGIN { use_ok('Lingua::ES::Numeros') };

#########################


sub parser {
    my $num;
    my ($s,$i,$f,$e);

    $num = join("_", split("", 9 x 9));

    ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num($num, ".", "_");
    ok( ($s == 1 and $i == 999999999 and $f == 0 and $e == 0) , "parse_num 1");
    
    ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("-$num", ".", "_");
    ok( ($s == -1 and $i == 999999999 and $f == 0 and $e == 0) , "parse_num 2");
    
    ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e-6", ".", "_");
    ok( ($s == 1 and $i == 999 and $f == 999999 and $e == 0) , "parse_num 3");
    
    ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e-9", ".", "_");
    ok( ($s == 1 and $i == 0 and $f == 999999999 and $e == 0) , "parse_num 4");

    ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e-18", ".", "_");
    ok( ($s == 1 and $i == 0 and $f == 999999999 and $e == -9) , "parse_num 5");
    
    ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e+6", ".", "_");
    ok( ($s == 1 and $i == 999999999 and $f == 0 and $e == 6) , "parse_num 6");

    my $n = join("_", split("", 9 x 6));
    $n .= "." . $n;
    for my $num ( $n, "+$n", "-$n" ) {
        my $st = $num =~ /^-/ ? -1 : 1;

        ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num($num, ".", "_");
        ok( ($s == $st and $i == 999999 and $f == 999999 and $e == 0) , "parse_num A");

        for my $xe ( qw/ e0 e+0 e-0 / ) {
            ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}$xe", ".", "_");
            ok( ($s == $st and $i == 999999 and $f == 999999 and $e == 0) , "parse_num B");
        }
        
        ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e-3", ".", "_");
        ok( ($s == $st and $i == 999 and $f == 999999999 and $e == 0) , "parse_num C");
        
        ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e-6", ".", "_");
        ok( ($s == $st and $i == 0 and $f eq "999999999999" and $e == 0) , "parse_num D");

        ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e-9", ".", "_");
        ok( ($s == $st and $i == 0 and $f eq "999999999999" and $e == -3) , "parse_num E");
        
        ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e+3", ".", "_");
        ok( ($s == $st and $i == 999999999 and $f == 999 and $e == 0) , "parse_num F");
        
        ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e+6", ".", "_");
        ok( ($s == $st and $i == "999999999999" and $f eq 0 and $e == 0) , "parse_num G");

        ($s,$i,$f,$e) = Lingua::ES::Numeros::parse_num("${num}e+9", ".", "_");
        ok( ($s == $st and $i == "999999999999" and $f eq 0 and $e == 3) , "parse_num H");
    }
}

parser;

