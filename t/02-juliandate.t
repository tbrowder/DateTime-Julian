use Test;
use DateTime::Julian;

plan 12;

my ($dt, $jd, $utc);

# test from Wikipedia data (see docs)
$jd = 2_451_545.0;
$dt = DateTime::Julian.new: :juliandate($jd);

is $dt.year, 2000, "year 2000";
is $dt.month, 1, "month 1";
is $dt.day, 1, "day 1";
is $dt.hour, 12, "hour 12";
is $dt.minute, 0, "minute 0";
is $dt.second, 0, "second 0";

# test from Wikipedia data (see docs)
$jd = 2_456_293.520833;
$dt = DateTime::Julian.new: :juliandate($jd);
is $dt.year, 2013;
is $dt.month, 1;
is $dt.day, 1;
is $dt.hour, 0;
is $dt.minute, 30;
is $dt.second, 0;

=finish

# tests from the JPL website:
#     https://ssd.jpl.nasa.gov/tc.cgi
my %utc =
    # utc => jd
    '3501-08-15T12:00:00.00Z' => 3000000.0,
    '3501-08-15T14:39:59.04Z' => 3000000.1111,
    '3501-08-15T23:59:51.36Z' => 3000000.4999,
    '3501-08-16T00:00:00.00Z' => 3000000.5,
    '3501-08-16T00:00:00.86Z' => 3000000.50001,
;

for %utc -> $utc, $jd {
    my $dt = DateTime::Julian.new: $utc;
    is $dt.juliandate, $jd;
}

# reverse and test the key/values to ensure they round trip okay
my %jd = %utc.invert;

for %jd -> $jd, $utc {
    my $dt = DateTime::Julian.new: :juliandate($jd);
    is $dt.utc, $utc;
}

