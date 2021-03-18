unit module Time;

use Math::FractionalPart :afrac;

#| decimal hours to hms
sub hours2hms($x --> List) is export(:hours2hms) {
    # hours must be a fraction of a day of 24 hours     
    die "FATAL: Input \$x ($x) must be >= 0 and < 24" if not (0 <= $x < 24);
    my $hreal = $x;
    my $h = truncate $hreal;
    my $m = truncate(60 * afrac($hreal));
    my $s = 60 * afrac(60 * afrac($hreal));
    $h, $m, $s;
}



