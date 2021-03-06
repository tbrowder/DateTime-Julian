unit module DateTime::Julian::APC;

#| This code is a Raku version of some of the algorithms described
#| in "Astronomy on the Personal Computer" by Oliver Montenbruck
#| and Thomas Pfleger. It was generated from the descriptions
#| in the book with additions and modifications by this author
#| to take advantage of Raku features. In addition, some 
#| routines have alias names to fit the author's style of coding,
#| e.g., kebob- and lower-case names.
#|
#| Export tags have been added to indicate the types of routines:
#|   :apc-time
#|   :apc-position
#|   :apc-math
#|   :raku

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
sub Frac(Real \x --> Real) is export(:apc-math) {
    x - x.floor
}

# p. 8
sub Modulo(Real \x, Real \y --> Real) is export(:apc-math) {
    y * Frac(x/y)
}

# p. 9
sub Ddd(Int \D, Int \M, Real \S, :$debug --> Real) is export(:apc-position) {
    # max of 360 degrees for output
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
    #$sign * (D.abs + M.abs/60.0 + S.abs/3600.0)
    # output should not exceed 360
    my $ang = D.abs + M.abs/60.0 + S.abs/3600.0;
    $ang %= 360 if $ang > 360;
    $sign * $ang
}

# p. 9
sub DMS(Real \Dd, 
    Int $D is rw, Int $M is rw, Real $S is rw,
    :$debug) is export(:apc-position) {
    my Real $x = Dd.abs;
    # max of 360 degrees for angle use
    # (but what if it's being used for JD or MJD?)
    if $x > 360 {
        note qq:to/HERE/;
        WARNING: Input Dd ($x) is greater than 360.
                 It is assumed to be an angle and will be normalized
                    by modulo 360. 
        HERE
    }
    $x %= 360 if $x > 360;

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
    if $debug {
        note "DEBUG output from end of DMS: Dd ({Dd}) => $D  $M  $S";
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
#   code (I can use both with the same name)
#   12 chars??
#   '       %5.2f'    [7 leading spaces]
#   '       %2d %2d'  [7 leading spaces]
#   '    %2d %5.2f'   [4 leading spaces]
#   '    %2d %2d %2d' [4 leading spaces]
#   '%3d %2d %5.2f'
sub Angle(Real $angle is copy, AngleFormat = Dd) is export(:apc-position) {
    # max of 360 degrees
    $angle %= 360 if $angle > 360;
    
}
class Angle is export(:apc-position) {
    has Real $.angle;
    has AngleFormat $.Format = Dd;
    method new($angle is copy, AngleFormat $Format = Dd) {
        # max of 360 degrees
        $angle %= 360 if $angle > 360;
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
sub mjd2jd($mjd) is export(:apc-time, :raku) {
    $mjd + MJDdelta
}

# p. 14
sub jd2mjd($jd) is export(:apc-time, :raku) {
    $jd - MJDdelta
}

# p. 15
# Modified Julian Date from calendar date and time
# Raku wrappers
sub cal2mjd(Int :$year, Int :$month, Int :$day,
            Int :$hour = 0, Int :$minute = 0, Real :$second = 0.0,
            :$debug = 0 --> Real) is export(:raku) {
    Mjd $year, $month, $day, $hour, $minute, $second;
}
sub Mjd(Int $Year is copy, Int $Month is copy, Int \Day,
        Int \Hour = 0, Int \Min = 0, Real \Sec = 0.0 
        --> Real) is export(:apc-time) {

    if $Month <= 2 {
        $Month += 12;
        --$Year;
    }
    my Int $b;
    if (10_000 * $Year + 100 * $Month + Day) <= 15_821_004 {
        $b = -2 + (($Year + 4_716) div 4) - 1_179;              # Julian calendar
    }
    else {
        $b = ($Year div 400) - ($Year div 100) + ($Year div 4); # Gregorian calendar
    }
    
    my Int \MjdMidnight = 365 * $Year - 679_004 + $b + Int(30.6001 * ($Month + 1)) + Day;
    my \FracOfDay = Ddd(Hour, Min, Sec) / 24.0;

    return MjdMidnight + FracOfDay;
}

# p. 16
# Calendar date and time from Modified Julian Date
#   output:
#     calendar date components
#     decimal hours
# Raku wrapper
multi sub CalDat(
    Real \Mjd,
    Int $Year is rw, Int $Month is rw, Int $Day is rw, Real $Hour is rw,
    :$debug
    ) is export(:apc-time) {

    # convert Julian day number to calendar date
    my Int \a = Int(Mjd + 2_400_001.0);
    my (Int $b, Int $c);
    if a < 2_299_161 { # Julian calendar
        $b = 0;
        $c = a + 1_524;
    }
    else {             # Gregorian calendar
        $b = Int((a - 1_867_216.25) / 36_524.25);
        $c = a + $b - ($b div 4) + 1_525;
    }
    my Int \d = Int(($c - 122.1) / 365.25);
    my Int \e = 365 * d + (d div 4);
    my Int \f = Int(($c - e) / 30.6001);

    # calculate the returned values
    $Day   = $c - e - Int(30.6001 * f);
    $Month = f - 1 - 12 * (f div 14);
    $Year  = d - 4_715 - ((7 + $Month) div 10);
    my \FracOfDay = Mjd - floor(Mjd);
    $Hour = 24.0 * FracOfDay; 
}

# p. 16
# Calendar date and time from Modified Julian Date
#   output:
#     calendar date components
#     time components
# Raku wrappers
sub jd2dt(:$jd, 
    --> DateTime) is export(:raku) {
    my $mjd = jd2mjd $jd;
    mjd2dt :$mjd; 
}

sub mjd2dt(
    :$mjd!, 
    :$debug --> DateTime) is export(:raku) {

    my Int $year;
    my Int $month;
    my Int $day;
    my Int $hour;
    my Int $minute;
    my Real $second;

    # collect results
    CalDat $mjd, $year, $month, $day, $hour, $minute, $second;

    # from the results, create and return a DateTime object
    my $dt = DateTime.new: :$year, :$month, :$day, :$hour, :$minute, :$second;
    return $dt;
}

multi sub CalDat(
    Real \Mjd,
    Int $Year is rw, Int $Month is rw, Int $Day is rw, 
    Int $Hour is rw, Int $Min is rw, Real $Sec is rw,
    :$debug,
    ) is export(:apc-time) {
    my Real $Hours;
    CalDat Mjd, $Year, $Month, $Day, $Hours;
    DMS $Hours, $Hour, $Min, $Sec, :$debug;
    # no explicitly returned values
}
 
# p. 17
enum TimeFormat is export(:apc-time) (
    None   => 1, # no time, date only
    DDd    => 2, # output time as fraction of a day
    HHh    => 3, # output time as hours with one decimal place
    HHMM   => 4, # output time as hours and minutes (rounded to the next minute)
    HHMMSS => 5, # output time as hours, min, sec (rounded to next sec)
    DTSTR  => 6, # output time as Raku DateTime.Str: '[+|-]YYYY-MM-DDThh:mm:ss.ssZ'
);

# p. 16
sub Time(Real $hour is copy, TimeFormat $format = HHMMSS, :$debug) is export(:apc-time) {
    # first get the time decomposed, use routine DMS 
    #   sub DMS(Real \Dd, Int $D is rw, Int $M is rw, Real $S is rw) is export(:apc-position) {
    # assume the hour input is < 24 (i.e., less than a day)
    if $hour >= 24 {
        note qq:to/HERE/;
        WARNING: Input \$hour ($hour) is >= 24 (i.e., a day or more).
                 It is assumed to be a fraction of a single day 
                 and will be normalized
                    by modulo 24. 
        HERE
        $hour %= 24;
    }

    my (Int $h, Int $m, Real $s);
    DMS $hour, $h, $m, $s, :$debug;
    given $format {
        when /None/   { # no time, date only
        }
        when /DDd/    { # output time as fraction of a day
        }
        when /HHh/    { # output time as hours with one decimal place
        }
        when /HHMM/   { # output time as hours and minutes (rounded to the next minute)
        }
        when /HHMMSS/ { # output time as hours, min, sec (rounded to next sec)
        }
        when /DTSTR/  { # output time as Raku DateTime.Str: '[+|-]YYYY-MM-DDThh:mm:ss.ssZ'
        }
    }
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



