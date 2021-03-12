package Astro::Montenbruck::MathUtils;

use 5.22.0;
use feature qw/signatures/;
no warnings qw/experimental::signatures/;
# The line below disables wrong perlcritic warnings
## no critic qw/Subroutines::ProhibitSubroutinePrototypes/

use Exporter qw/import/;
use POSIX qw (floor ceil acos modf fmod);
use List::Util qw/any reduce/;

use Math::Trig qw/:pi :radial deg2rad rad2deg/;
use constant { ARCS => 3600.0 * 180.0 / pi };

our %EXPORT_TAGS = (
    all => [
        qw/frac frac360 dms hms zdms ddd polynome sine
          reduce_deg reduce_rad to_range opposite_deg opposite_rad
          angle_s angle_c angle_c_rad diff_angle polar cart quad
          ARCS/
    ],
);
our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
our $VERSION = 0.02;

sub frac($x) { ( modf($x) )[0] }

sub frac360($x) { frac($x) * 360 }

sub dms ( $x, $places = 3 ) {
    return $x if $places == 1;

    my ( $f, $i ) = modf($x);
    $f = -$f if $i != 0 && $f < 0;

    ( $i, dms( $f * 60, $places - 1 ) );
}

sub hms { dms @_ }

sub zdms($x) {
    my ( $d, $m, $s ) = dms($x);
    my $z = int( $d / 30 );
    $d %= 30;

    $z, $d, $m, $s;
}

sub ddd(@args) {
    my $b = any { $_ < 0 } @args;
    my $sgn = $b ? -1 : 1;
    my ( $d, $m, $s ) = map { abs( $args[$_] || 0 ) } ( 0 .. 2 );
    return $sgn * ( $d + ( $m + $s / 60.0 ) / 60.0 );
}

sub polynome ( $t, @terms ) {
    reduce { $a * $t + $b } reverse @terms;
}

sub to_range ( $x, $limit ) {
    $x = fmod( $x, $limit );
    $x < 0 ? $x + $limit : $x;
}

#sub reduce_deg($x) { to_range( $x, 360 ) }

sub reduce_deg($x) {
    my $res = Math::Trig::deg2deg($x);
    $res < 0 ? $res + 360 : $res;
}

#sub reduce_rad($x) { to_range( $x, pi2 ) }

sub reduce_rad($x) {
    my $res = Math::Trig::rad2rad($x);
    $res < 0 ? $res + pi2 : $res;
}

sub sine($x) { sin( pi2 * frac($x) ) }

sub opposite_deg($x) { reduce_deg( $x + 180 ) }

sub opposite_rad($x) { reduce_rad( $x + pi ) }

sub angle_c ( $a, $b ) {
    my $x = abs( $a - $b );
    $x > 180 ? 360 - $x : $x;
}

sub angle_c_rad ( $a, $b ) {
    my $x = abs( $a - $b );
    $x > pi ? pi2 - $x : $x;
}

sub angle_s {
    my ( $x1, $y1, $x2, $y2 ) = map { deg2rad $_ } @_;
    rad2deg(
        acos( sin($y1) * sin($y2) + cos($y1) * cos($y2) * cos( $x1 - $x2 ) ) );
}

sub diff_angle($a, $b, $mode = 'degrees') {
    my $m = lc $mode;
    my $whole = $m eq 'degrees' ? 360
                                : $m eq 'radians' ? pi2
                                                  : undef;
    die "Expected 'degrees' or 'radians' mode" unless $whole;
    my $half = $m eq 'degrees' ? 180 : pi;
    my $x = $b < $a ? $b + $whole : $b;
    $x -= $a;
    return $x - $whole if $x > $half;
    return $x;
}


sub cart( $r, $theta, $phi ) {
    my $rcst = $r * cos($theta);
    $rcst * cos($phi), $rcst * sin($phi), $r * sin($theta);
}

# in previous versions was named 'polar'
sub polar ( $x, $y, $z ) {
    my $rho = $x * $x + $y * $y;
    my $r   = sqrt( $rho + $z * $z );
    my $phi = atan2( $y, $x );
    $phi += pi2 if $phi < 0;
    $rho = sqrt($rho);
    my $theta = atan2( $z, $rho );
    $r, $theta, $phi;
}

sub quad {
    my ( $y_minus, $y_0, $y_plus ) = @_;
    my $nz = 0;
    my $a  = 0.5 * ( $y_minus + $y_plus ) - $y_0;
    my $b  = 0.5 * ( $y_plus - $y_minus );
    my $c  = $y_0;

    my $xe  = -$b / ( 2 * $a );
    my $ye  = ( $a * $xe + $b ) * $xe + $c;
    my $dis = $b * $b - 4 * $a * $c;          # discriminant of y = axx+bx+c
    my @zeroes;
    if ( $dis >= 0 ) {

        # parabola intersects x-axis
        my $dx = 0.5 * sqrt($dis) / abs($a);
        @zeroes[ 0, 1 ] = ( $xe - $dx, $xe + $dx );
        $nz++ if abs( $zeroes[0] ) <= 1;
        $nz++ if abs( $zeroes[1] ) <= 1;
        $zeroes[0] = $zeroes[1] if $zeroes[0] < -1;
    }
    $nz, $xe, $ye, @zeroes;
}
