use Test;

use DateTime::Julian;
use Math::FractionalPart :frac;

plan 16;

# check some miscellanous calculations

# from Perl module Astro::Montenbruck, script/simple_ephem.pl
my $jd = 2458630.5;
my $t = ($jd - 2451545)/36525;
my $d = DateTime::Julian.new: :julian-date($jd);
is $d.c2000, $t;

# subs from Montenbruck, p. 8
# show they are the same as the Raku versions
sub Frac($x) {
    # same as Math::FractionalPart.frac
    $x - $x.floor
}
sub Modulo($x, $y) {
    # same as Raku infix % operator 
    $y * Frac($x/$y)
}

my $a = 1.24;
my $b = 1.1;
my $c = -2.3;
is Frac($a), 0.24;
is Frac($b), 0.1;
is Frac($c), 0.7;
is Frac($a), frac($a);
is Frac($b), frac($b);
is Frac($c), frac($c);

is Modulo($a,$a), ($a % $a);
is Modulo($a,$b), ($a % $b);
is Modulo($a,$c), ($a % $c);

is Modulo($b,$a), ($b % $a);
is Modulo($b,$b), ($b % $b);
is Modulo($b,$c), ($b % $c);

is Modulo($c,$a), ($c % $a);
is Modulo($c,$b), ($c % $b);
is Modulo($c,$c), ($c % $c);

# test the Ephemeris Time given on 
# p. 43 of Montenbruck
my $dt = DateTime::Julian.new: "1982-01-01T00:00:00Z";
say $dt.second;

