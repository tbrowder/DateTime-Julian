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
        $!juliandate = utc2jd self.datetime;
    }
}

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

our $formatter is export(:formatter) = sub ($self) {
    sprintf "%04d-%02d-%02dT%02d:%02d:%05.2fZ",
        .year, .month, .day, .hour, .minute, .second
        given $self;
}

sub jd2utc(Real $jd is copy, :$is-julian-calendar = False --> DateTime) is export(:jd2utc) {
    # Source of date algorithm is from CPAN module Astro::Montenbruck::Time :jd2cal

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
    
    # tmp hack
    return DateTime.now
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

# aliases
method utc { self.datetime }
method jd  { self.juliandate }
method dt  { self.datetime }
method Str { self.datetime.Str }
# expose normal dt methods
method year    { self.dt.year }
method month   { self.dt.month }
method day     { self.dt.day }
method hour    { self.dt.hour }
method minute  { self.dt.minute }
method second  { self.dt.second }
