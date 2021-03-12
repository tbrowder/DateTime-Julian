unit module TimeUtils;

our $VERSION = 0.01;

our $SEC_PER_DAY = 86400;        # Seconds per day
our $SEC_PER_CEN = 3155760000;
our $J2000       = 2451545;      # Standard Julian Date for 1.1.2000 12:00
our $J1900       = 2415020
  ;    # Standard Julian Date for  31.12.1899 12:00 (astronomical epoch 1900.0)
our $SOLAR_TO_SIDEREAL = 1.002737909350795
  ;    # Difference in between Sidereal and Solar hour (the former is shorter)
our $GREGORIAN_START = 15821004;    # Start of Gregorian calendar (YYYYMMDD)
our $JD_UNIX_EPOCH = _gmtime2jd( gmtime(0) )
  ; # Standard Julian date for the beginning of Unix epoch, Jan 1 1970 on most Unix systems

sub after_gregorian is export(:ALL) {
    my $y   = shift;
    my $m   = shift;
    my $d   = shift;
    my %arg = ( gregorian_start => $GREGORIAN_START, @_ );
    return 0 unless defined %arg{gregorian_start};
    polynome( 100, $d, $m, $y ) >= %arg{gregorian_start};
}

sub cal2jd is export(:ALL) {
    my $ye  = shift;
    my $mo  = shift;
    my $da  = shift;
    my %arg = ( gregorian_start => $GREGORIAN_START, @_ );

    my $j = $da + 1720996.5;
    my ( $m, $y ) = ( $mo > 2 ) ? ( $mo, $ye ) : ( $mo + 12, $ye - 1 );
    if ( after_gregorian( $ye, $mo, $da, %arg ) ) {
        $j += int( $y / 400 ) - int( $y / 100 ) + int( $y / 4 );
    }
    else {
        $j += int( ( $y + 4716 ) / 4 ) - 1181;
    }
    $j + 365 * $y + floor( 30.6001 * ( $m + 1 ) );
}

sub jd2cal is export(:ALL) {
    my $jd = shift;
    my %arg = ( gregorian => 1, @_ );

    my ( $f, $i ) = modf( $jd - $J1900 + 0.5 );
    if ( %arg{gregorian} && $i > -115860 ) {
        my $a = floor( $i / 36524.25 + 9.9835726e-1 ) + 14;
        $i += 1 + $a - floor( $a / 4 );
    }

    my $b  = floor( $i / 365.25 + 8.02601e-1 );
    my $c  = $i - floor( 365.25 * $b + 7.50001e-1 ) + 416;
    my $g  = floor( $c / 30.6001 );
    my $da = $c - floor( 30.6001 * $g ) + $f;
    my $mo = $g - ( $g > 13.5 ? 13 : 1 );
    my $ye = $b + ( $mo < 2.5 ? 1900 : 1899 );
    $ye, $mo, $da;
}

sub jd0 is export(:ALL) {
    my $j = shift;
    floor( $j - 0.5 ) + 0.5;
}

sub unix2jd is export(:ALL) {
    $JD_UNIX_EPOCH + $_[0] / $SEC_PER_DAY;
}

sub jd2unix is export(:ALL) {
    int( ( $_[0] - $JD_UNIX_EPOCH ) * $SEC_PER_DAY );
}

sub _gmtime2jd is export(:ALL) {
    cal2jd( $_[5] + 1900, $_[4] + 1, $_[3] + ddd( @_[ 2, 1, 0 ] ) / 24 );
}

sub jdnow is export(:ALL) {
    _gmtime2jd( gmtime() );
}

sub jd2mjd is export(:ALL) {
    $_[0] - $J2000;
}

sub mjd2jd is export(:ALL) {
    $_[0] + $J2000;
}

# converts Julian date to period in centuries since epoch
# Arguments:
# julian date
# julian date corresponding to the epoch start
sub _t is export(:ALL) {
    my ( $jd, $epoch ) = @_;
    ( $jd - $epoch ) / 36525;
}

sub jd_cent is export(:ALL) {
    _t( $_[0], $J2000 );
}

sub t1900 is export(:ALL) {
    _t( $_[0], $J1900 );
}

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

sub is_leapyear is export(:ALL) {
    my $yr = shift;
    my %arg = ( gregorian => 1, @_ );
    $yr = int($yr);
    return %arg{gregorian}
      ? ( $yr % 4 == 0 ) && ( ( $yr % 100 != 0 ) || ( $yr % 400 == 0 ) )
      : $yr % 4 == 0;
}

sub day_of_year is export(:ALL) {
    my $yr = shift;
    my $mo = shift;
    my $dy = shift;

    my $k = is_leapyear($yr, @_) ? 1 : 2;
    $dy = int($dy);
    int(275 * $mo / 9.0) - ($k * int(($mo + 9) / 12.0)) + $dy - 30
}
