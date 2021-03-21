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

#| hours, minutes, seconds to decimal fraction of 24 hours
sub hms2days($h, $m, $s) is export(:hms2days) {
    my $ds  = $h * 3600;  # hours to seconds
    $ds    += $m * 60;    # add minutes to seconds
    $ds    += $s;         # add the seconds
    return $ds/(24*3600); # back to fraction of a day
}


