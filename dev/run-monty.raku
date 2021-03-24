#!/usr/bin/env raku

use lib <./.>;
use APC;

# use each func
my $x = 16.23;
my $y = -6.1256;

say (Frac $x);
say (Frac $y);
say (Modulo $x, $y);

my $d = 409;
my $m = 65;
my $s = 76.12;
my $res = Ddd $d, $m, $s;
say $res;

my $a = Angle.new($d);
say $a.cout;


