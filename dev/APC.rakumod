unit module APC;

#| This code is a Raku version of the algorithms described
#| in "Astronomy on the Personal Computer" by Oliver Montenbruck
#| and Thomas Pfleger.

# p. 8
sub Frac(Real \x --> Real) is export {
    x - x.floor
}

# p. 8
sub Modulo(Real \x, Real \y --> Real) is export {
    y * Frac(x/y)
}

# p. 9
sub Ddd(Int \D, Int \M, Real \S, :$debug --> Real) is export {
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
sub DMS(Real \Dd, Int $D is rw, Int $M is rw, Real $S is rw) is export {
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
enum AngleFormat is export ( 
    Dd      => 1,      # decimal repr
    DMM     => 2,     # deg and whole min of arc
    DMMm    => 3,    # deg and min of arc in decimal repr
    DMMSS   => 4,   # deg, min of arc and whole sec of arc
    DDMMSSs => 5, # deg, min, sec of arc in decimal repr
);

# pp. 9-10
# TODO complete the class output formats:
#   12 chars??
#   '       %5.2f'    [7 leading spaces]
#   '       %2d %2d'  [7 leading spaces]
#   '    %2d %5.2f'   [4 leading spaces]
#   '    %2d %2d %2d' [4 leading spaces]
#   '%3d %2d %5.2f'
class Angle is export {
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

# p. 15
sub Mjd(Int $Year is copy, Int $Month is copy, Int \Day,
        Int \Hour = 0, Int \Min = 0, Real \Sec = 0.0 
        --> Real) is export {

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
multi sub CalDat(
    Real \Mjd,
    Int $Year is rw, Int $Month is rw, Int $Day is rw, Real $Hour is rw
    ) is export {
}

# p. 16
multi sub CalDat(
    Real \Mjd,
    Int $Year is rw, Int $Month is rw, Int $Day is rw, 
    Int $Hour is rw, Int $Min is rw, Real $Sec is rw
    ) is export {
    my Real $Hours;
    CalDat Mjd, $Year, $Month, $Day, $Hours;
    DMS $Hours, $Hour, $Min, $Sec;
}
 
# p. 17
enum TimeFormat is export (
    None   => 1, # no time, date only
    DDd    => 2, # output time as fraction of a day
    HHh    => 3, # output time as hours with one decimal place
    HHMM   => 4, # output time as hours and minutes (rounded to the next minute)
    HHMMSS => 5, # output time as hours, min, sec (rounded to next sec)
);

# p. 16
class Time is export {
    has Real $.Hour;
    has TimeFormat $.Format = HHMMSS;
    method new(Real $Hour, TimeFormat $Format = HHMMSS) {
        return self.bless(:$Hour, :$Format)
    }
    method cout(AngleFormat $Format?) {
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
class Datetime is export {
    has Real $.Mjd;
    has TimeFormat $.Format = None;
    method new(Real $Mjd, TimeFormat $Format = HHMMSS) {
        return self.bless(:$Mjd, :$Format)
    }
    method cout(AngleFormat $Format?) {
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



