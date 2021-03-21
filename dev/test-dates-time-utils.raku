#!/usr/bin/env raku

use lib <./.>;
#use MathUtils :ALL;
use TimeUtils :jd2cal, :cal2jd, :jd2cal2, :cal2jd2;
use Time :hours2hms, :hms2days;
use Math::FractionalPart :afrac;

#note "DEBUG: early exit";exit;

my %utc =
    # tests from the JPL website:
    #     https://ssd.jpl.nasa.gov/tc.cgi
    '3501-08-15T12:00:00.00Z' => 3000000.0,
    '3501-08-15T14:39:59.04Z' => 3000000.1111,
    '3501-08-15T23:59:51.36Z' => 3000000.4999,
    '3501-08-16T00:00:00.00Z' => 3000000.5,
    '3501-08-16T00:00:00.86Z' => 3000000.50001,
;

# reverse to test the key/values to ensure they round trip okay
my %jd = %utc.invert;

for %jd.keys.sort -> $jd {
    my $in = $jd;
    my $out = %jd{$jd};
    #my ($year, $month, $day) = jd2cal $jd;
    my ($year, $month, $day, $hr) = jd2cal2 $jd;

    #say "fail:  '$in'   ne    '$out'" if $in ne $out;
    say "input jd: '$jd'";

    #say "  y/m/d = $year $month $day";
    #say "  y/m/d = $year $month $day $hr";

    # convert decimal hours to hms format
    my ($hour, $minute, $second) = hours2hms $hr;
    #say "     h/m/s = $hour  $minute $second";

    # get a DateTime object
    my $dt = DateTime.new: :$year, :$month, :$day, :$hour, :$minute, :$second;
    say "   JPL     output: '$out'";
    say "   jd2cal2 output: '{$dt.Str}'";

}

for %utc.keys.sort -> $utc {
    my $jdin = %utc{$utc};
    my $dt   = DateTime.new: $utc;
    say "\$dt input: '{$dt.Str}'";

    my ($year, $month, $day, $hour, $minute, $second) = 
        $dt.year, $dt.month, $dt.day, $dt.hour, $dt.minute, $dt.second;
    # convert day/hour/minute/second to day.decimalhms
    my $decday = hms2days $hour, $minute, $second;
    $decday += $day;
    my $jd = cal2jd $year, $month, $decday;
    #my $jd = cal2jd2 $year, $month, $decday;

    say "jd: '$jd'";
    say "   JPL jd output: '{$jdin}'";
    # how many decimal places?
    my $nplaces = nplaces $jdin;
    # round output to same number decimal places
    my $jdr = $jd;
    if $nplaces {
        $jdr = sprintf '%0.*f', $nplaces, $jd;
    }

    say "   cal2jd output: '{$jdr}'";
    #is $dt.utc, $utc;
}

sub nplaces($x) {
    my $frac = afrac $x;
    if $frac == 0 {
        return 0;
    }
    my $nplaces = (($x - $x.truncate).abs).chars - 2;
    $nplaces;
}

