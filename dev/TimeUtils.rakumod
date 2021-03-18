unit module TimeUtils;

# Raku additions:
use Time::gmtime; # a Raku module

use POSIX:from<Perl5> qw/modf/;
use MathUtils :ALL;

our $VERSION = 0.01;

our $SEC_PER_DAY is export = 86400;        # Seconds per day
our $SEC_PER_CEN is export = 3155760000;
our $J2000       is export = 2451545;      # Standard Julian Date for 1.1.2000 12:00
our $J1900       is export = 2415020
  ;    # Standard Julian Date for  31.12.1899 12:00 (astronomical epoch 1900.0)
our $SOLAR_TO_SIDEREAL is export = 1.002737909350795
  ;    # Difference in between Sidereal and Solar hour (the former is shorter)
our $GREGORIAN_START is export = 15821004;    # Start of Gregorian calendar (YYYYMMDD)

#our $JD_UNIX_EPOCH is export = _gmtime2jd( gmtime(0) )
  ; # Standard Julian date for the beginning of Unix epoch, Jan 1 1970 on most Unix systems


#| =head2 after_gregorian($year, $month, $date, gregorian_start => $YYYYMMDD )
#|
#| Does the given date fall to period after Gregorian calendar?
#|
#| =head3 Positional Arguments
#|
#|
#| =item1 B<year> (astronomic, zero-based)
#|
#| =item1 B<month> (1-12)
#|
#| =item1 B<date> UTC date (1-31) with hours and minutes as decimal part
#|
#|
#| =head3 Optional Named Arguments
#|
#|
#| =item1 B<gregorian_start> — start of Gregorian calendar. Default value is
#| B<15821004> If the date is Julian ("old style"), use C<undef> value.
#| To provide non-standard start of Gregorian calendar, provide a number
#| in format YYYYMMDDD, e.g. C<19180126> for Jan 26, 1918.
#|
#|
#| =head3 Returns
#|
#| I<true> or I<false>.
sub after_gregorian($y, $m, $d, :$gregorian_start) is export(:ALL) {
    =begin comment
    my $y   = shift;
    my $m   = shift;
    my $d   = shift;
    my %arg = ( gregorian_start => $GREGORIAN_START, @_ );
    return 0 unless defined %arg{gregorian_start};
    polynome( 100, $d, $m, $y ) >= %arg{gregorian_start};
    =end comment
    return 0 unless defined $gregorian_start and $gregorian_start;
    polynome( 100, [$d, $m, $y] ) >= $gregorian_start;
}

#| cal2jd($year, $month, $date)
#|
#| Convert civil date/time to Standard Julian date.
#|
#| If the C<gregorian_start> argument is not provided, it is assumed that
#| this is a date of the I<Proleptic Gregorian calendar>, which started
#| at Oct. 4, 1582.
#|
#| Positional Arguments:
#|
#| =item1 B<year> (astronomic, zero-based)
#|
#| =item1 B<month> (1-12)
#|
#| =item1 B<date> UTC date (1-31) with hours and minutes as decimal part
#|
#| =head3 Optional Named Arguments
#|
#| =item1 gregorian_start — start of Gregorian calendar. Default value is
#| B<15821004> If the date is Julian ("old style"), use C<undef> value.
#| To provide non-standard start of Gregorian calendar, provide a number
#| in format YYYYMMDDD, e.g. C<19180126> for Jan 26, 1918.
#|
#| =head3 Returns
#|
#| Standard Julian date
sub cal2jd($ye, $mo, $da, :$gregorian_start) is export(:cal2jd) {
    =begin comment
    my $ye  = shift;
    my $mo  = shift;
    my $da  = shift;
    my %arg = ( gregorian_start => $GREGORIAN_START, @_ );
    =end comment

    my $j = $da + 1720996.5;
    my ( $m, $y ) = ( $mo > 2 ) ?? ( $mo, $ye ) !! ( $mo + 12, $ye - 1 );
    #if ( after_gregorian( $ye, $mo, $da, %arg ) ) {
    if ( after_gregorian( $ye, $mo, $da, :$gregorian_start ) ) {
        $j += Int( $y / 400 ) - Int( $y / 100 ) + Int( $y / 4 );
    }
    else {
        $j += Int( ( $y + 4716 ) / 4 ) - 1181;
    }
    $j + 365 * $y + floor( 30.6001 * ( $m + 1 ) );
}

#| jd2cal($jd)
#|
#| Convert Standard Julian date to civil date/time
#|
#| Positional Arguments
#|
#|   jd - Standard Julian Date
#|
#| Optional Named Arguments
#|
#|   gregorian - if true, the result will be old-style (Julian) date
#|
#| Returns
#|
#| A list corresponding to the input values of the cal2jd($year, $month, $date) function.
#| The date is given in the proleptic Gregorian calendar system unless B<gregorian>
#| flag is set to true>
sub jd2cal($jd, :$gregorian) is export(:jd2cal) {
    =begin comment
    my $jd = shift;
    my %arg = ( gregorian => 1, @_ );
    =end comment

    my ( $f, $i ) = modf( $jd - $J1900 + 0.5 );
    #if ( %arg{gregorian} && $i > -115860 ) {
    if ( $gregorian && $i > -115860 ) {
        my $a = floor( $i / 36524.25 + 9.9835726e-1 ) + 14;
        $i += 1 + $a - floor( $a / 4 );
    }

    my $b  = floor( $i / 365.25 + 8.02601e-1 );
    my $c  = $i - floor( 365.25 * $b + 7.50001e-1 ) + 416;
    my $g  = floor( $c / 30.6001 );
    my $da = $c - floor( 30.6001 * $g ) + $f;
    my $mo = $g - ( $g > 13.5 ?? 13 !! 1 );
    my $ye = $b + ( $mo < 2.5 ?? 1900 !! 1899 );
    $ye, $mo, $da;
}


sub jd0($j) is export(:ALL) {
    =begin comment
    my $j = shift;
    =end comment
    floor( $j - 0.5 ) + 0.5;
}

=begin comment
sub unix2jd() is export(:ALL) {
    $JD_UNIX_EPOCH + $_[0] / $SEC_PER_DAY;
}

sub jd2unix() is export(:ALL) {
    int( ( $_[0] - $JD_UNIX_EPOCH ) * $SEC_PER_DAY );
}
=end comment

sub _gmtime2jd(*@) {
    #sub cal2jd($ye, $mo, $da, :$gregorian_start) is export(:ALL) {
    #cal2jd( $_[5] + 1900, $_[4] + 1, $_[3] + ddd( @_[ 2, 1, 0 ] ) / 24 );
    cal2jd( @[5] + 1900, @[4] + 1, @[3] + ddd(@[ 2, 1, 0 ] ) / 24 );
}

sub jdnow() is export(:ALL) {
    _gmtime2jd( gmtime() );
}

sub jd2mjd() is export(:ALL) {
    $_[0] - $J2000;
}

sub mjd2jd() is export(:ALL) {
    $_[0] + $J2000;
}

# converts Julian date to period in centuries since epoch
# Arguments:
# julian date
# julian date corresponding to the epoch start
sub _t {
    my ( $jd, $epoch ) = @_;
    ( $jd - $epoch ) / 36525;
}

sub jd_cent is export(:ALL) {
    _t( $_[0], $J2000 );
}

sub t1900 is export(:ALL) {
    _t( $_[0], $J1900 );
}

=begin comment
sub jd2gst is export(:ALL) {
    my $jh = shift;
    my $j0 = jd0($jh);
    my $s0 = polynome( t1900($j0), 0.276919398, 100.0021359, 0.000001075 );
    24 * ( frac($s0) + abs( $jh - $j0 ) * $SOLAR_TO_SIDEREAL );
}

sub jd2lst is export(:ALL) {
    my ( $jd, $lon ) = @_;
    $lon //= 0;
    to_range( jd2gst($jd) - $lon / 15, 24 );
}
=end comment

sub is_leapyear($yr, :$gregorian) is export(:ALL) {
    =begin comment
    my $yr = shift;
    my %arg = ( gregorian => 1, @_ );
    $yr = int($yr);
    return %arg{gregorian}
    =end comment
    return $gregorian
      ?? ( $yr % 4 == 0 ) && ( ( $yr % 100 != 0 ) || ( $yr % 400 == 0 ) )
      !! $yr % 4 == 0;
}

sub day_of_year($yr, $mo, $dy, :$gregorian) is export(:ALL) {
    =begin comment
    my $yr = shift;
    my $mo = shift;
    my $dy = shift;
    =end comment

    my $k = is_leapyear($yr, :$gregorian) ?? 1 !! 2;
    $dy = int($dy);
    int(275 * $mo / 9.0) - ($k * int(($mo + 9) / 12.0)) + $dy - 30
}

#=finish
# code from Sergey below
# sub jd2cal renamed jd2cal2 for the moment

constant DJD_TO_JD = 2415020; # aka: $J1900;

# function Int?
sub fni ($x) {
    return sign($x) * truncate(abs($x));
}

# least-integer function
# function ceiling?
sub fnl($x) {
    return fni($x) + fni((sign($x) - 1.0) / 2.0);
}

sub jd2cal2($jd) is export(:jd2cal2) {
    my $dj = $jd - DJD_TO_JD;
    my $d = $dj + 0.5;
    my $i = fnl($d);
    my $fd = $d - $i;

    # If time is 24:00 then increment day
    if ($fd == 1) {
        $fd = 0;
        $i++;
    }
    # Deal with Gregorian change
    if ($i > -115860) {
        my $a = fnl( ($i / 36524.25) + 9.9835726E-1) + 14;
        $i += 1 + $a - fnl($a / 4);
    }
    my $b = fnl($i / 365.25 + 8.02601e-1);
    my $c = $i - fnl(365.25 * $b + 7.50001e-1) + 416;
    my $g = fnl($c / 30.6001);
    my $dh = $c - fnl(30.6001 * $g) + $fd;
    my $mo = $g - ($g > 13.5 ?? 13 !! 1);
    my $ye = $b + ($mo < 2.5 ?? 1900 !! 1899);
    # convert astronomical, zero-based year to civil
    if ($ye < 1) {
      $ye--;
    }
    my $hm = ($dh - truncate($dh)) * 24.0;
    my $da = truncate($dh);
    return ($ye, $mo, $da, $hm);
}

