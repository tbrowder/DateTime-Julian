use Test;
use DateTime::Julian :ALL;

plan 12;

my ($dt, $jd, $utc);

=begin comment
and Lunar cycles) and which preceded any dates in recorded history. For example,
the Julian day number for the day starting at 12:00 UT (noon) on January 1, 2000,
was B<2451545>.
=end comment
$jd = 2451545.0;
$dt = DateTime::Julian.new: :juliandate($jd);
is $dt.year, 2000;
is $dt.month, 1;
is $dt.day, 1;
is $dt.hour, 12;
is $dt.minute, 0;
is $dt.second, 0;

=begin comment
For example, the Julian date for 00:30:00.0 UT January 1, 2013,
is B<2456293.520833>.
=end comment
$jd = 2456293.520833;
$dt = DateTime::Julian.new: :juliandate($jd);
is $dt.year, 2013;
is $dt.month, 1;
is $dt.day, 1;
is $dt.hour, 0;
is $dt.minute, 30;
is $dt.second, 0;


pass "replace me";

done-testing;
