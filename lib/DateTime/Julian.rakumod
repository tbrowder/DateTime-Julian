unit class DateTime::Julian:ver<0.0.1>:auth<cpan:TBROWDER> is DateTime is export;

# The official start date for the Gregorian calendar
# was October 15, 1582.
#constant GC = DateTime.new: :1582year, :10month, :15day;
constant POS0 = 2_440_587.5; # JD in Gregorian calendar (1970-01-01T00:00:00Z)
constant MJD0 = 2_400_000.5; # JD in Gregorian calendar (1858-11-17T00:00:00Z)
constant sec-per-day = 86_400;

method new(:$julian-date, :$modified-julian-date) {
    # Convert the input value to the suitable POSIX value
    # to instantiate the DateTime object.
    my $JD;
    if $julian-date.defined {
        $JD = $julian-date
    }
    elsif $modified-julian-date.defined {
        # Use relationship: MJD = JD - MJD0 => JD = MJD + MJD0
        $JD = $modified-julian-date + MJD0
    }
    else {
        die "FATAL: No value provided to DateTime::Julian.new"
    }
 
    # Given the Julian Date (JD) of an instant, determine its Gregorian UTC
    my $days = $JD - POS0;          # days from the POSIX epoch to the desired JD
    my $psec = $days * sec-per-day; # days x seconds-per-day

    # from @lizmat, IRC #raku, 2021-03-29  11:50
    self.DateTime::new($psec); # The desired Gregorian UTC
}

=finish

use DateTime::Julian::APC :ALL;

has $.juliandate;

=begin comment
has Real $.modifiedjuliandate;
# aliases
has Real $.jdate;
has Real $.mjdate;
=end comment

# other desirable attributes

submethod BUILD(:$!juliandate) {
}

submethod TWEAK {
    my $new-is-julian = 0;
=begin comment
    # choose the input to use and fill in the remainder
    if $!juliandate.defined {
        $!jdate = $!juliandate;
        $!mjdate = jd2mjd $!jdate;
        $!modifiedjuliandate = $!mjdate;
        ++$new-is-julian;
    }
    elsif $!jdate.defined {
        $!juliandate = $!jdate;
        $!mjdate = jd2mjd $!jdate;
        $!modifiedjuliandate = $!mjdate;
        ++$new-is-julian;
    }
    elsif $!modifiedjuliandate.defined {
        $!mjdate = $!modifiedjuliandate;
        $!jdate = mjd2jd $!mjdate;
        $!juliandate = $!jdate;
        ++$new-is-julian;
    }
    elsif $!mjdate.defined {
        $!modifiedjuliandate = $!mjdate;
        $!jdate = mjd2jd $!mjdate;
        $!juliandate = $!jdate;
        ++$new-is-julian;
    }
    else {
        # we must have been instantiated via the DateTime methods
        # which should not be a show-stopper
        $!mjdate = cal2mjd :year(self.year), :month(self.month), :day(self.day), 
                           :hour(self.hour), :minute(self.minute), :second(self.second);
        $!modifiedjuliandate = $!mjdate;
        $!jdate = mjd2jd $!mjdate;
        $!juliandate = $!jdate;
    }
=end comment

    if $new-is-julian {
        # now we use jdate or mjdate as needed
        # to set the DateTime attributes from the Julian date input
        my $dt   = jd2dt $!juliandate;
        self.year   = $dt.year;
        self.month  = $dt.month;
        self.day    = $dt.day;
        self.hour   = $dt.hour;
        self.minute = $dt.minute;
        self.second = $dt.second;
    }
}

our $formatter is export(:formatter) = sub ($self) {
    sprintf "%04d-%02d-%02dT%02d:%02d:%05.2fZ",
        .year, .month, .day, .hour, .minute, .second
        given $self;
}

=finish

multi sub utc2jd(
    DateTime $dt,
    :$is-julian-calendar = False --> Real) is export(:utc2jd) {
    # Source of date algorithm is from CPAN module Astro::Montenbruck::Time :cal2jd

    =begin comment
    # book from Amazon)
    my \Y = $dt.year;
    my \M = $dt.month;
    my \D = $dt.day;
    my $jdn = (1461 * (Y+4800 + (M-14)/12))/4+(367*(M-2-12 * ((M-14)/12)))/12-(3*((Y+4900+(M-14)/12)/100))/4+D-32075;
    my $h = $dt.hour;
    my $m = $dt.minute;
    my $s = $dt.second;
    my $hms = $h-12/24 + $m/1440 + $s/86400;
    # check UT time of day in case a JD increase is needed
    # "For a point in time in a given Julian day after midnight UTC and before 12:00 UT,
    # add 1 or uses the JDN of the next afternoon."
    my $dt-noon = DateTime.new: :year($dt.year), :month($dt.month), :day($dt.day), :hour(12), :minute(0), :second(0);
    $jdn += 1 if $dt < $dt-noon;
    $jdn += $hms;
    return $jdn;
    =end comment
}

multi sub utc2jd(
    $utc, #= a date string in the '$formatter' format
    :$is-julian-calendar = False --> Real) is export(:utc2jd) {
    my $dt = DateTime.new: $utc;
    return utc2jd $dt, :$is-julian-calendar;
}

sub jd2utc(Real $jd is copy, :$is-julian-calendar = False --> DateTime) is export(:jd2utc) {
    # Source of date algorithm is from CPAN module Astro::Montenbruck::Time :jd2cal
    # as rewritten in an email to this author from Sergey Krushinsky. See the dev
    # directory.

    # So how do we get the UTC value? Here is a table to help visualize the
    # two values (note that 0.5 is 12 hours:
    #
    #     UTC                                       Julian date
    #     D   00:00  day starts at midnight         J-1 .5
    #     D   06:00                                 J-1 .75
    #     D   12:00                                 J   .0   Julian day starts at UTC noon
    #     D   18:00                                 J   .25
    #     D   24:00  day D ends as day D+1 starts   J   .5
    #     D+1 00:00  day D+1                        J   .5

}

sub frac($x) is export(:frac) {
    return $x.abs - $x.Int.abs
}

#| decimal hours to hms
sub dayfrac2hms($x, :$debug --> List) is export(:dayfrac2hms) {
    # hours must be a fraction of a day of 24 hours
    die "FATAL: Input \$x ($x) must be >= 0 and < 1" if not (0 <= $x < 1);
    my $hreal = 24 * $x;
    my $h = $hreal.Int;
    my $m = (60 * frac($hreal)).Int;
    # seconds are rounded to 2
    my $s = 60 * frac(60 * frac($hreal));
    my $s2 = $s.round(0.0001);
    note "DEBUG: \$s = $s, \$s2 = $s2" if $debug;
    $h, $m, $s2;
}

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

sub nplaces($x) is export(:nplaces) {
    my $frac = afrac $x;
    if $frac == 0 {
        return 0;
    }
    my $nplaces = (($x - $x.truncate).abs).chars - 2;
    $nplaces;
}

=finish
# aliases
#method utc { self.datetime }
#method jd  { self.juliandate }
#method dt  { self.datetime }
#method Str { self.datetime.Str }

=begin comment
# expose normal dt methods
method year    { self.dt.year }
method month   { self.dt.month }
method day     { self.dt.day }
method hour    { self.dt.hour }
method minute  { self.dt.minute }
method second  { self.dt.second }
=end comment
