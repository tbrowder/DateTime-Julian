unit module DateTime::Julian::APC;

#| This code is a Raku version of some of the algorithms described
#| in "Astronomy on the Personal Computer" by Oliver Montenbruck
#| and Thomas Pfleger.

# some constants
# from pp. 7-8:
constant pi2      is export(:apc-position) = 2.0 * pi;
constant Rad      is export(:apc-position) = pi / 180.0;
constant Deg      is export(:apc-position) = 180.0 / pi;
constant Arcs     is export(:apc-position) = 3_600.0 * 180.0 * pi;
constant AU       is export(:apc-position) = 149_597_870.0; # kilometers
constant c-light  is export(:apc-position) = 173.14; # AU/d
# from p. 14 in subs mjd2jd and jd2mjd:
constant MJDdelta is export(:apc-time) = 2_400_000.5; 

# p. 8
sub Frac(Real \x --> Real) is export(:Frac) {
    x - x.floor
}

# p. 8
sub Modulo(Real \x, Real \y --> Real) is export(:Modulo) {
    y * Frac(x/y)
}

# p. 9
sub Ddd(Int \D, Int \M, Real \S, :$debug --> Real) is export(:Ddd) {
    my $sign = (D < 0 or M < 0 or S < 0) ?? -1 !! 1;
    if $debug {
        note qq:to/HERE/;
        DEBUG: routine Ddd
            input D: {D}
            input M: {M}
            input S: {S}
            D.abs  : {D.abs}
            M.abs/60.0 : {M.abs/60.0}                                                                           
            S.abs/60.0 : {S.abs/3600.0}                                                                            
        HERE
    }
    $sign * (D.abs + M.abs/60.0 + S.abs/3600.0)
}

# p. 9
sub DMS(Real \Dd, Int $D is rw, Int $M is rw, Real $S is rw) is export(:DMS) {
    my $x = Dd.abs;
    $D = $x.Int;

    $x = ($x - $D) * 60.0;
    $M = $x.Int;
    $S = ($x - $M) * 60.0;

    if Dd < 0.0 {
        if $D != 0 {
            $D *= -1;
        }
        elsif $M != 0 {
            $M *= -1;
        }
        else {
            $S *= -1.0;
        }
    }
}

# p. 9
enum AngleFormat is export(:apc-position) ( 
    Dd      => 1, # decimal repr
    DMM     => 2, # deg and whole min of arc
    DMMm    => 3, # deg and min of arc in decimal repr
    DMMSS   => 4, # deg, min of arc and whole sec of arc
    DDMMSSs => 5, # deg, min, sec of arc in decimal repr
);

# pp. 9-10
# TODO complete the class output formats:
#   also, these classes may be better used as multi subs, depending on use in real
#   code (I can I use both with the same name?)
#   12 chars??
#   '       %5.2f'    [7 leading spaces]
#   '       %2d %2d'  [7 leading spaces]
#   '    %2d %5.2f'   [4 leading spaces]
#   '    %2d %2d %2d' [4 leading spaces]
#   '%3d %2d %5.2f'
sub Angle(Real $angle, AngleFormat = Dd) is export(:apc-position) {
}
class Angle is export(:apc-position) {
    has Real $.angle;
    has AngleFormat $.Format = Dd;
    method new($angle, AngleFormat $Format = Dd) {
        return self.bless(:$angle, :$Format)
    }
    method Set(AngleFormat $Format = Dd) {
        self.Format = $Format
    }
    method cout(AngleFormat $Format?) {
        my $fmt = $Format ?? $Format !! self.Format;
        given $fmt {
            when /Dd/ { 
                'Dd'
            }
            when /DMM/ { 
                'DMM'
            }
            when /DMMm/ { 
                'DMMm'
            }
            when /DMMSS/ { 
                'DMMSS'
            }
            when /DDMMSSs/ { 
                'DDMMSSs'
            }
        }
    }
}

# p. 14
# MJD is total number of days elapsed since 1858-11-17T00:00
sub mjd2jd($mjd) is export(:apc-time) {
    $mjd + MJDdelta
}

# p. 14
sub jd2mjd($jd) is export(:apc-time) {
    $jd - MJDdelta
}

# p. 15
# Modified Julian Date from calendar date and time
sub Mjd(Int $Year is copy, Int $Month is copy, Int \Day,
        Int \Hour = 0, Int \Min = 0, Real \Sec = 0.0 
        --> Real) is export(:apc-time) {

    if $Month <= 2 {
        $Month += 12;
        --$Year;
    }
    my $b;
    if (10_000 * $Year + 100 * $Month + Day) <= 15_821_004 {
        $b = -2 + (($Year + 4_716)/4) - 1_179; # Julian calendar
    }
    else {
        $b = ($Year/400) - ($Year/100) + ($Year/4); # Gregorian calendar
    }
    
    my \MjdMidnight = 365 * $Year - 679_004 + $b + Int(30.6001 * ($Month + 1)) + Day;
    my \FracOfDay = Ddd(Hour, Min, Sec) / 24.0;

    return MjdMidnight + FracOfDay;
}

# p. 16
# Calendar date and time from Modified Julian Date
#   output:
#     calendar date components
#     decimal hours
multi sub CalDat(
    Real \Mjd,
    Int $Year is rw, Int $Month is rw, Int $Day is rw, Real $Hour is rw
    ) is export(:apc-time) {
    # convert Julian day number to calendar date
    my \a = Mjd + 2_400_001.0;
    my ($b, $c);
    if a < 2_299_161 { # Julian calendar
        $b = 0;
        $c = a + 1524;
    }
    else {             # Gregirian calendar
        $b = (a - 1_867_216.25) / 36_524.25;
    }
    my \d = ($c - 122.1) / 365.25;
    my \e = 365 * d + d/4;
    my \f = ($c - e) / 30.6001;

    # calculate the returned values
    $Day = $c - e - Int(30.6001 * f);
    $Month = f - 1 - 12 * (f/14);
    $Year = d - 4_715 - (7 + $Month)/10;
    my \FracOfDay = Mjd - floor(Mjd);
    $Hour = 24.0 * FracOfDay; 
}

# p. 16
# Calendar date and time from Modified Julian Date
#   output:
#     calendar date components
#     time components
multi sub CalDat(
    Real \Mjd,
    Int $Year is rw, Int $Month is rw, Int $Day is rw, 
    Int $Hour is rw, Int $Min is rw, Real $Sec is rw
    ) is export(:apc-time) {
    my Real $Hours;
    CalDat Mjd, $Year, $Month, $Day, $Hours;
    DMS $Hours, $Hour, $Min, $Sec;
}
 
# p. 17
enum TimeFormat is export(:apc-time) (
    None   => 1, # no time, date only
    DDd    => 2, # output time as fraction of a day
    HHh    => 3, # output time as hours with one decimal place
    HHMM   => 4, # output time as hours and minutes (rounded to the next minute)
    HHMMSS => 5, # output time as hours, min, sec (rounded to next sec)
);

# p. 16
sub Time(Real $hour, TimeFormat = HHMMSS) is export(:apc-time) {
}
class Time is export(:apc-time) {
    has Real $.Hour;
    has TimeFormat $.Format = HHMMSS;
    method new(Real $Hour, TimeFormat $Format = HHMMSS) {
        return self.bless(:$Hour, :$Format)
    }
    method cout(TimeFormat $Format?) {
        my $fmt = $Format ?? $Format !! self.Format;
        given $fmt {
            when /None/ {
                'None'
            }
            when /DDd/ { 
                'DDd'
            }
            when /HHh/ { 
                'HHh'
            }
            when /HHMM/ { 
                'HHMM'
            }
            when /HHMMSS/ { 
                'HHMMSS'
            }
        }
    }
}

# p. 16
# NOTE class 'Datetime' is renamed from the original name to avoid 
# conflict with Raku's DateTime class.
sub Datetime(Real $Mjd, TimeFormat = None) is export(:apc-time) {
}
class Datetime is export(:apc-time) {
    has Real $.Mjd;
    has TimeFormat $.Format = None;
    method new(Real $Mjd, TimeFormat $Format = HHMMSS) {
        return self.bless(:$Mjd, :$Format)
    }
    method cout(TimeFormat $Format?) {
        my $fmt = $Format ?? $Format !! self.Format;
        given $fmt {
            when /None/ {
                'None'
            }
            when /DDd/ { 
                'DDd'
            }
            when /HHh/ { 
                'HHh'
            }
            when /HHMM/ { 
                'HHMM'
            }
            when /HHMMSS/ { 
                'HHMMSS'
            }
        }
    }
}



