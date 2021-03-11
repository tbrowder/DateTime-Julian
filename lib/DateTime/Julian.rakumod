unit class DateTime::Julian:ver<0.0.1>:auth<cpan:TBROWDER>;

has DateTime $.datetime;
has Real     $.juliandate;

submethod TWEAK {
    if not self.datetime.defined and not self.juliandate.defined {
        die "FATAL: You must defined one only of 'datetime' or 'juliandate'";
    }
    if self.datetime.defined and self.juliandate.defined {
        die "FATAL: You must define one only of 'datetime' or 'juliandate'";
    }
    if self.juliandate.defined {
        $!datetime = jd2utc self.juliandate;
    }
    else {
        $!juliandate = utc2jd self.utc;
    }
}

sub utc2jd($utc, :$is-julian = False --> Real) is export(:utc2jd) {
    my $dt = DateTime.new: $utc;
}

sub jd2utc(Real $jd is copy, :$is-julian = False --> DateTime) is export(:jd2utc) {
    # Source of date algorithm is from Wikipedia (from Richards, 1998 and 2013; I have ordered the 1998
    # book from Amazon)

    $jd += 0.5; # from Lawrence, see p. 42, step 1

    # TODO: this is INCOMPLETE!!
    #       how do we get the time of day????
    # save the fractional part
    my $hours = $jd.abs - $jd.truncate.abs; # same as a "frac" routine

    =begin comment
    my $day-correction = 0;
    if $hours > 24 {
        ++$day-correction;
    }
    =end comment

    my ($hour, $minute, $second) = dayfrac2hms $hours;

    # constants
    constant y = 4716;
    constant j = 1401;
    constant m = 2;
    constant n = 12;
    constant r = 4;
    constant p = 1461;
    constant v = 3;
    constant u = 5;
    constant s = 153;
    constant w = 2;
    constant B = 274277;
    constant C = -38;

    my \J = $jd.truncate;

    # step 1
    my $f = J + j + (((4 * J + B) div 146097) * 3) div 4 + C;
    $f = J + j if $is-julian;
    my \f = $f;

    # step 2
    my \e = r * f + v;

    # step 3
    my \g = (e mod p) div r;

    # step 4
    my \h = u * g + w;

    # step 5
    my \D = (h mod s) div u + 1;

    # step 6
    my \M = ((h div s + m) mod n) + 1;

    # step 7
    my \Y = (e div p) - y + (n + m - M) div n;

    # From the description of the algorithm:
    #
    # "D, M, and Y are the numbers of the day, month, and year, respectively,
    # for the afternoon at the beginning of the given Julian day."
    #
    # From the Wikipedia definition of a Julian date:
    #
    # "The Julian date (JD) of any instant is the Julian day number plus the fraction
    # of a day since the preceding noon in Universal Time. Julian dates are
    # expressed as a Julian day number with a decimal fraction added."
    #
    # So how do we get the UTC value? Here is a table to help visualize the
    # two values (note that 0.5 is 12 hours:
    #
    #     UTC              Julian date
    #     D-1 00:00        J   .0        days start at midnight
    #     D-1 06:00        J   .25
    #     D-1 12:00        J   .5
    #     D-1 18:00        J   .75
    #     D-1 24:00        J+1 .0        day N ends as day N+1 starts
    #     D   00:00        J+1 .0        day N
    #
    # Rules:
    #
    # The algorithm gives us the Julian date expressed in YYYY-MM-DD format.
    # If the
    return DateTime.new(:year(Y), :month(M), :day(D), :$hour, :$minute, :$second);
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
    my $s2 = $s.round(0.01);
    note "DEBUG: \$s = $s, \$s2 = $s2" if $debug;
    $h, $m, $s2;
}

# aliases
method utc { self.datetime }
method jd  { self.juliandate }
method dt  { self.datetime }
# expose normal dt methods
method year    { self.dt.year }
method month   { self.dt.month }
method day     { self.dt.day }
method hour    { self.dt.hour }
method minute  { self.dt.minute }
method second  { self.dt.second }
