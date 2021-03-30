#!/usr/bin/env raku

# SOURCE
# https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/15285/versions/25/previews/geodetic/cal2jd.m/index.html

=begin comment

Matlab function fix description:

"Y = fix(X)" rounds each element of X to the nearest integer toward zero. 
This operation effectively truncates the numbers in X to integers by 
removing the decimal portion of each number:

  + For positive numbers, the behavior of fix is the same as floor.

  + For negative numbers, the behavior of fix is the same as ceil.

=end comment


sub cal2jd($yr, $mn where {0 < $_ < 13}, $dy) is export(:cal2jd) {
    # CAL2JD  Converts calendar date to Julian date using algorithm
    #   from "Practical Ephemeris Calculations" by Oliver Montenbruck
    #   (Springer-Verlag, 1989). Uses astronomical year for B.C. dates
    #   (2 BC = -1 yr). Non-vectorized version. See also DOY2JD, GPS2JD,
    #   JD2CAL, JD2DOW, JD2DOY, JD2GPS, JD2YR, YR2JD.
    # Version: 2011-11-13
    # Usage:   jd=cal2jd(yr,mn,dy)
    # Input:   yr - calendar year (4-digit including century)
    #          mn - calendar month
    #          dy - calendar day (including fractional day)
    # Output:  jd - jJulian date

    # Copyright (c) 2011, Michael R. Craymer
    # All rights reserved.
    # Email: mike@craymer.com

    if $dy < 1 {
        #if (mn == 2 & dy > 29) | (any(mn == [3 5 9 11]) & dy > 30) | (dy > 31)
        if ($mn == 2 && $dy > 29) || (($mn ~~ /3|5|9|11/) && $dy > 30) || ($dy > 31) {
            die "Invalid input day: '$yr/$mn/$dy'";
            return;
        }
    }

    my ($y, $m, $b);
    if $mn > 2 {
        $y = $yr;
        $m = $mn;
    }
    else {
        $y = $yr - 1;
        $m = $mn + 12;
    }

    my $date1 =  4.5 + 31 * (10 + 12 * 1582);  # Last day of Julian calendar (1582.10.04 Noon)
    my $date2 = 15.5 + 31 * (10 + 12 * 1582);  # First day of Gregorian calendar (1582.10.15 Noon)
    my $date  = $dy  + 31 * ($mn + 12 * $yr);

    if $date <= $date1 {
        $b = -2;
    }
    elsif $date >= $date2 {
        #b = fix(y/400) - fix(y/100);
        $b = floor($y/400) - floor($y/100);
    }
    else {
        die "Dates between October 5 & 15, 1582 do not exist, you entered: '$yr/$mn/$dy'";
        return;
    }

    my $jd;
    if $y > 0 {
        $jd = floor(365.25 * $y) + floor(30.6001 * ($m + 1)) + $b + 1720996.5 + $dy;
    }
    else {
        $jd = floor(365.25 * $y - 0.75) + floor(30.6001 * ($m + 1)) + $b + 1720996.5 + $dy;
    }
}
