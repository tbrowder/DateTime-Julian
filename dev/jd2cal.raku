#!/usr/bin/env raku

use lib <./.>;
#use MathUtils :ALL;
#use TimeUtils :jd2cal, :cal2jd, :jd2cal2, :cal2jd2;
use Time :hours2hms, :hms2days;
use Math::FractionalPart :afrac;

#note "DEBUG: early exit";exit;

my %utc =
    # tests from the JPL website:
    #     https://ssd.jpl.nasa.gov/tc.cgi
    # entered UTC, got Julian
    '3501-08-15T12:00:00.00Z' => 3000000.0,
    '3501-08-15T14:39:59.04Z' => 3000000.1111,
    '3501-08-15T23:59:51.36Z' => 3000000.4999,
    '3501-08-16T00:00:00.00Z' => 3000000.5,
    '3501-08-16T00:00:00.86Z' => 3000000.50001,
    '-3501-08-16T00:00:00.86Z' => 2000000.50001,
;

# reverse to test the key/values to ensure they round trip okay
my %jd = %utc.invert;

our $formatter is export(:formatter) = sub ($self) {
    sprintf "%04d-%02d-%02dT%02d:%02d:%05.2fZ",
        .year, .month, .day, .hour, .minute, .second
        given $self;
}

for %jd.keys.sort -> $jd {
    my $in  = $jd;
    my $exp = %jd{$jd};
    #my ($year, $month, $day) = jd2cal $jd;
    my ($year, $month, $day) = jd2cal $jd;

    #say "fail:  '$in'   ne    '$out'" if $in ne $out;
    say "input jd: '$jd'";

    say "  y/m/d = $year $month $day";

    next;

    =begin comment
    #say "  y/m/d = $year $month $day $hr";

    # convert decimal hours to hms format
    my ($hour, $minute, $second) = hours2hms $hr;
    #say "     h/m/s = $hour  $minute $second";

    # get a DateTime object
    my $dt = DateTime.new: :$year, :$month, :$day, :$hour, :$minute, :$second, :$formatter;
    say "   JPL     output: '$out'";
    say "   jd2cal2 output: '{$dt.Str}'";
    =end comment

}

sub nplaces($x) {
    my $frac = afrac $x;
    if $frac == 0 {
        return 0;
    }
    my $nplaces = (($x - $x.truncate).abs).chars - 2;
    $nplaces;
}

sub modf($x) {
    # splits $x into integer and fractional parts
    # note the sign of $x is applied to BOTH parts
    my $int-part  = $x.Int;
    my $frac-part = $x - $int-part;
    [$frac-part, $int-part];
}

sub jd2cal($jd, :$gregorian = True) {
    # Standard Julian Date for  31.12.1899 12:00 (astronomical epoch 1900.0)
    my constant $J1900 = 2415020;
    my ($f, $i) = modf( $jd - $J1900 + 0.5 );
    note "DEBUG: input to modf: {$jd - $J1900 + 0.5} => \$f ($f), \$i ($i)" if 1;

    if $gregorian && $i > -115860  {
        my $a = floor( $i / 36524.25 + 9.9835726e-1 ) + 14;
        $i += 1 + $a - floor( $a / 4 );
    }

    my $b  = floor( $i / 365.25 + 8.02601e-1 );
    my $c  = $i - floor( 365.25 * $b + 7.50001e-1 ) + 416;
    my $g  = floor( $c / 30.6001 );
    my $da = $c - floor( 30.6001 * $g ) + $f;
    my $mo = $g - ( $g > 13.5 ?? 13 !! 1 );
    my $ye = $b + ( $mo < 2.5 ?? 1900 !! 1899 );
    # Note $da is a Real number
    $ye, $mo, $da;
}
