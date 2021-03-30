#!/usr/bin/env raku

use lib <. ../lib>;
use DateTime::Julian; 
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

# try the heavy duty subs
# first we use the "raw" CalDat and Mjd subs

#my (Int $year, Int $month, Int $day, Int $hour, Int $minute, Real $second) = 2021, 3, 25, 1, 2, 32.8;
my ($year, $month, $day, $hour, $minute, $second) = 2021, 3, 25, 1, 2, 32.8;
my $mjd = Mjd $year, $month, $day, $hour, $minute, $second;
say "mjd from cal: $mjd";

$mjd += 26.321;
($year, $month, $day, $hour, $minute, $second) = 0, 0, 0, 0, 0, 0;
CalDat $mjd, $year, $month, $day, $hour, :debug;
say "from CalDat mjd $mjd: $year, $month, $day, $hour";


($year, $month, $day, $hour, $minute, $second) = 2021, 3, 25, 1, 2, 32.8;
my $mjd = cal2mjd :$year, :$month, :$day, :$hour, :$minute, :$second;
my $jd = mjd2jd $mjd;
say "mjd: $mjd";
say "jd: $jd";

my $dt = jd2dt :$jd;
say "dt for jd $jd = '{$dt.utc}'";

my $de = DateTime.new: $jd;
say "de for jd $jd = '{$de.utc}'";

=finish

#$dt = DateTime::Julian.new :$year, :$month, :$day, :$hour, :$minute, :$second;
$dt = DateTime::Julian.new: :100year; #: :juliandate($jd);
say $dt.Str;
$dt = DateTime::Julian.new: :100juliandate;
say $dt.Str;
