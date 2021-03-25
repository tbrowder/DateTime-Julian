#!/usr/bin/env raku

use lib <. ../lib>;
use DateTime::Julian::APC :ALL;

# use each func
my $x = 16.23;
my $y = -6.1256;

say (Frac $x);
say (Frac $y);
say (Modulo $x, $y);

my $d = 409;
my $m = 65;
my $s = 76.12;
say "dms in: $d $m $s";
my $dec = Ddd $d, $m, $s;
say "dec out: $dec";

my $a = Angle.new($d);
say $a.cout;

($d, $m, $s) = 410, 1, 32.6;
say "dms in: $d $m $s";
$dec = Ddd $d, $m, $s;
say "dec out: $dec";
$dec += 400.1111111111;

DMS $dec, $d, $m, $s;
say "in: $dec, out: $d $m $s";
$dec *= -1;
DMS $dec, $d, $m, $s;
say "in: $dec, out: $d $m $s";

=finish
 
sub DMS(Real \Dd, Int $D is rw, Int $M is rw, Real $S is rw) is export(:DMS) {
