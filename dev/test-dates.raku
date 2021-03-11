#!/usr/bin/env raku

use lib <../lib ./lib>;
use DateTime::Julian :ALL;

my %utc =
    # utc => jd
    # tests from Wikipedia:
    '2000-01-02T12:00:00.00Z' => 2451545.0,
    '2013-01-01T00:30:00.00Z' => 2456293.520833,

    # tests from the JPL website:
    #     https://ssd.jpl.nasa.gov/tc.cgi
    '3501-08-15T12:00:00.00Z' => 3000000.0,
    '3501-08-15T14:39:59.04Z' => 3000000.1111,
    '3501-08-15T23:59:51.36Z' => 3000000.4999,
    '3501-08-16T00:00:00.00Z' => 3000000.5,
    '3501-08-16T00:00:00.86Z' => 3000000.50001,
;

# reverse and test the key/values to ensure they round trip okay
my %jd = %utc.invert;

for %jd.keys.sort -> $jd {
    my $utc = %jd{$jd};
    my $dt = DateTime::Julian.new: :juliandate($jd.Real);
    say "input: '{$utc}' output: '{$dt.utc.Str}'";
}

=finish

# reverse and test the key/values to ensure they round trip okay
my %jd = %utc.invert;

for %jd -> $jd, $utc {
    my $dt = DateTime::Julian.new: :juliandate($jd);
    is $dt.utc, $utc;
}


