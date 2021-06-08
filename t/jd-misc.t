use Test;

use DateTime::Julian;

plan 1;

# check some miscellanous calculations

# from Perl module Astro::Montenbruck, script/simple_ephem.pl
my $jd = 2458630.5;
my $t = ($jd - 2451545)/36525;
my $d = DateTime::Julian.new: :julian-date($jd);
is $d.c2000, $t;



