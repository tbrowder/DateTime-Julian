unit module EG-Richards;

use Text::Utils :strip-comment;

use Gen-Test :mon2num;

# This module contains algorithms from E. G. Richards.

# from Table 25.4 Parameters for calculating the Gregorian correction, p. 320
constant %GC = [
    10 => {
        cal => 'Gregorian',
        J0 => 4716,
        Y0 => 4716,
        g0 => 4716,
        A => 4716,
        B => 4716,
        G => 4716,
    },
];

# from Table 25.1 Parameters for the conversion of dates in regular calendars, p. 311
constant %RC is export = [
    10 => {
        cal => 'Julian Roman',
        y => 4716,
        j => 1401,
        m => 3,
        n => 12,
        r => 4,
        p => 1461,
        q => 0,
        v => 3,
        u => 5,
        s => 153,
        t => 2,
        w => 2,
    },
    11 => {
        cal => 'Gregorian',
        y => 4716,
        j => 1401, # WARNING: one must add 'g' to this value, see p. 319, Equation 25.26
        m => 3,
        n => 12,
        r => 4,
        p => 1461,
        q => 0,
        v => 3,
        u => 5,
        s => 153,
        t => 2,
        w => 2,
    },
];

sub g-for-input-Y'c(\Y'c) is export {
    # See Equation 25.26 on p. 319
}

sub g-for-input-J(\J) is export {
    # See Equation 25.34 on p. 320
}

sub day-frac2hms(Real $x, :$debug --> List) is export {
    # Converts the fraction of a day into hours, minutes,
    # and seconds"
    my $hours   = $x * 24;
    my $hour    = $hours.Int;
    my $minutes = ($hours - $hour) * 60;
    my $minute  = $minutes.Int;
    my $second  = ($minutes - $minute) * 60;
    $hour, $minute, $second
}

# note the following sub is obsolete now that Raku DateTime has
# method day-fraction
sub day-frac(DateTime:D $dt, :$debug --> Real) is export {
    # Converts the hours, minutes, and seconds of an
    # instant into the decimal fraction of a 24-hour day.
    constant sec-per-day = 24 * 60 * 60;
    # get seconds in this day
    my $frac = $dt.hour * 60 * 60;
    $frac += $dt.minute * 60;
    $frac += $dt.second;
    # the day fraction
    $frac /= sec-per-day;
}

sub cal2jd(\Y, \M, $D, 
           Bool :$gregorian!, 
           :$debug 
           --> Real
          ) is export {
    # Using Richards' Algorithm E, p. 323

    my \D = $D.Int;
    my \day-fraction = $D - D;

    # convert to the intermediate calendar form 
    my \Y'c = Y + y - (n + m - I - M) / n; # Eq. 25.1
    my \M'c = (M - m + n) mod r; # Eq. 25.2
    my \D'c = D - 1; # Eq. 25.3
    my \c = (p * Y'c + q) / r; # Eq. 25.8
    my \d = () / u; # Eq. 25.9

    # step 6
    my $J;
    if $gregorian {
        # for the Gregorian calendar input
        $J = c + d + D'c - j; # Eq. 25.7
    }
    else {
        # for the Julian calendar input
        my \g = ((Y'c + A) / 100) / 4 + G; # Eq. 25.26
        $J = c + d + D'c - j - g; # Eq. 25.22
    }
    my \J = $J;

    # add the day fraction back
    J + day-fraction
} # sub cal2jd

sub jd2cal($JD, 
           Bool :$gregorian!, 
           :$debug 
           --> List
          ) is export {
    # Using Richards' Algorithm F, p. 324
    my \J = $JD.Int;
    my \day-fraction = $JD - J;
    
    # step 1
    my $Jc;
    if $gregorian {
        my \g = 3 * ((4 * J + B) / 146097) / 4 + G; # Eq. 25.34
        $Jc = J + j + g; # Eq. 25.23
    }
    else {
        $Jc = J + j; # Eq. 25.10
    }
    my \J'c = $Jc;
    my \Y'c = () / p; # Eq. 25.11
    my \T'c = (() mod p) / r; # Eq. 25.12
    my \M'c = # Eq. 25.13
    my \D'c = # Eq. 25.14

    my \D = D'c + 1; # Eq. 25.4
    my \M = (() mod ) + 1; # Eq. 25.5
    my \Y = Y'c - y + () / n; # Eq. 25.6

    # add the day fraction back
    Y, M, D + day-fraction
} # sub jd2cal

sub gregorian2jd($y, $m, $d, :$debug --> Real) {
}

sub julian2jd($y, $m, $d, :$debug --> Real) {
}

sub jd2gregorian($jd, :$debug --> List) {
}

sub jd2julian($jd, :$debug --> List) {
}


