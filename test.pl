# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..5\n"; }
END {print "not ok 1\n" unless $loaded;}
use Lingua::ES::Numeros;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$obj = Lingua::ES::Numeros::new;

$l = $obj->cardinal(1001);
$t1 = "un mil uno";
print scalar($l ne $t1 ? "not " : ""), "ok 2\n"; 

$l = $obj->ordinal(1001);
$t1 = "milésimo primero";
print scalar($l ne $t1 ? "not " : ""), "ok 3\n"; 

$obj->{UNMIL} = 0;
$obj->{SEXO} = 'a';
$obj->{FORMATO} = 'con %s';
$l = $obj->real(1001001.001);
$t1 = "un millón mil una con una milésima";
print scalar($l ne $t1 ? "not " : ""), "ok 4\n"; 

$obj->{MAYUSCULAS} = 1;
$l = $obj->real(1001001.001);
$t1 = "UN MILLÓN MIL UNA CON UNA MILÉSIMA";
print scalar($l ne $t1 ? "not " : ""), "ok 5\n";

