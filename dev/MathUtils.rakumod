unit module MathUtils;

use POSIX:from<Perl5> qw (floor ceil acos modf fmod);
#use List::Util qw/any reduce/;
use List::Util <any reduce>;

use Math::Trig:from<Perl5> qw/:radial deg2rad rad2deg/;
constant pi2 is export = 2*pi;
constant ARCS is export = 3600.0 * 180.0 / pi;

our $VERSION = 0.02;

sub frac($x) is export(:frac) { ( modf($x) )[0] }

sub frac360($x) is export(:frac360) { frac($x) * 360 }

sub dms ( $x, $places = 3 ) is export(:dms) {
    return $x if $places == 1;

    my ( $f, $i ) = modf($x);
    $f = -$f if $i != 0 && $f < 0;

    ( $i, dms( $f * 60, $places - 1 ) );
}

sub hms is export(:hms) { dms @_ }

sub zdms($x) is export(:zdms) {
    my ( $d, $m, $s ) = dms($x);
    my $z = int( $d / 30 );
    $d %= 30;

    $z, $d, $m, $s;
}

sub ddd(@args) is export(:ddd) {
    any { $_ < 0 }, @args;
    my $b = shift @args;
    my $sgn = $b ?? -1 !! 1;
    my ( $d, $m, $s ) = map { abs( @args[$_] || 0 ) }, ( 0 .. 2 );
    return $sgn * ( $d + ( $m + $s / 60.0 ) / 60.0 );
}

sub polynome ( $t, @terms ) is export(:polynome) {
    #reduce { $a * $t + $b } reverse @terms;
    my $result = reduce -> $a, $b { $a * $t + $b }, @terms.reverse;
    $result;
}

sub to_range ( $x, $limit ) is export(:to_range) {
    $x = fmod( $x, $limit );
    $x < 0 ?? ($x + $limit) !! $x;
}

sub reduce_deg($x) is export(:reduce_deg) {
    my $res = Math::Trig::deg2deg($x);
    $res < 0 ?? ($res + 360) !! $res;
}

sub reduce_rad($x) is export(:reduce_rad) {
    my $res = Math::Trig::rad2rad($x);
    $res < 0 ?? ($res + pi2) !! $res;
}

#sub sine($x) is export(:sine) { sin( pi2 * frac($x) ) }

sub opposite_deg($x) is export(:opposite_deg) { reduce_deg( $x + 180 ) }

sub opposite_rad($x) is export(:opposite_rad) { reduce_rad( $x + pi ) }

sub angle_c ( $a, $b ) is export(:angle_c ) {
    my $x = abs( $a - $b );
    $x > 180 ?? (360 - $x) !! $x;
}

sub angle_c_rad ( $a, $b ) is export(:angle_c_rad) {
    my $x = abs( $a - $b );
    $x > pi ?? (pi2 - $x) !! $x;
}

sub angle_s is export(:angle_s) {
    my ( $x1, $y1, $x2, $y2 ) = map { deg2rad $_ }, @_;
    rad2deg(
        acos( sin($y1) * sin($y2) + cos($y1) * cos($y2) * cos( $x1 - $x2 ) ) );
}

sub diff_angle($a, $b, $mode = 'degrees') is export(:diff_angle) {
    my $m = lc $mode;
    my $whole = $m eq 'degrees' ?? 360
                                !! ($m eq 'radians') ?? pi2
                                                     !! Nil;
    die "Expected 'degrees' or 'radians' mode" unless $whole;
    my $half = $m eq 'degrees' ?? 180 !! pi;
    my $x = $b < $a ?? ($b + $whole) !! $b;
    $x -= $a;
    return $x - $whole if $x > $half;
    return $x;
}


sub cart( $r, $theta, $phi ) is export(:cart) {
    my $rcst = $r * cos($theta);
    $rcst * cos($phi), $rcst * sin($phi), $r * sin($theta);
}

# in previous versions was named 'polar'
sub polar ( $x, $y, $z ) is export(:polar) {
    my $rho = $x * $x + $y * $y;
    my $r   = sqrt( $rho + $z * $z );
    my $phi = atan2( $y, $x );
    $phi += pi2 if $phi < 0;
    $rho = sqrt($rho);
    my $theta = atan2( $z, $rho );
    $r, $theta, $phi;
}

sub quad is export(:quad) {
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
        $nz++ if abs( @zeroes[0] ) <= 1;
        $nz++ if abs( @zeroes[1] ) <= 1;
        @zeroes[0] = @zeroes[1] if @zeroes[0] < -1;
    }
    $nz, $xe, $ye, @zeroes;
}
