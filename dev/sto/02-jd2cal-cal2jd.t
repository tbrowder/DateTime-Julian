use Test;
use DateTime::Julian :ALL;

plan 20;

my %utc =
    # tests from the JPL website:
    #     https://ssd.jpl.nasa.gov/tc.cgi
    '3501-08-15T12:00:00.00Z' => 3000000.0,
    '3501-08-15T14:39:59.04Z' => 3000000.1111,
    '3501-08-15T23:59:51.36Z' => 3000000.4999,
    '3501-08-16T00:00:00.00Z' => 3000000.5,
    '3501-08-16T00:00:00.86Z' => 3000000.50001,
;

for %utc.keys.sort -> $utc {
    my $utin  = DateTime.new: $utc;
    my $jdexp = %utc{$utc};

    my ($year, $month, $day, $hour, $minute, $second) =
        $utin.year, $utin.month, $utin.day, $utin.hour, $utin.minute, $utin.second;
    # convert day/hour/minute/second to day.decimalhms
    my $decimalday = hms2days $hour, $minute, $second;
    $decimalday += $day;
    my $jd = utc2jd $year, $month, $decimalday;

    # how many decimal places?
    my $nplaces = nplaces $jdexp;
    # round output to same number decimal places
    my $jdround = $jd;
    if $nplaces {
        $jdround = sprintf '%0.*f', $nplaces, $jd;
    }
    is $jdround, $jdexp, 'convert UT to JD';
}

# reverse to test the key/values to ensure they round trip okay
my %jd = %utc.invert;

for %jd.keys.sort -> $jd {
    my $jdin  = $jd;
    my $utexp = %jd{$jd};
    my ($year, $month, $day, $hr) = jd2utc $jd;

    # convert decimal hours to hms format
    my ($hour, $minute, $second) = hours2hms $hr;

    # get a DateTime object
    my $ut = DateTime.new: :$year, :$month, :$day, :$hour, :$minute, :$second;
    is $ut.Str, $utexp.Str, 'convert JD to UT';
}
