#!/usr/bin/env raku

my $ifil   = 'jpl-test-data.dat';
my $ofil2  = '02-APC-jpl-time-tests.t';
my $ofil2n = '02-APC-jpl-time-tests-BC.t';
my $ofilr  = 'juliandate.t';
my $ofilrd = 'juliandate.t.draft';

class T {
    has $.era  is rw;
    has $.date is rw;
    has $.time is rw;
    has $.dow  is rw; # Monday, Tuesday, etc.
    has $.jd   is rw;
    has $.dts  is rw; # the DateTime.Str repr
    has $.day-of-week is rw; # DateTime number (Mon = 1, Sun = 7)
    has $.year is rw;
    has $.day-frac is rw;
    has $.doy  is rw; # 1..367
}

=begin comment
# one block of data from a JPL date/time <=> julian date tranformation:
<pre>

<b>Input Time Zone: UT</b>
-------------------------------------------------------
B.C. 4000-Jan-01 11:59:59.99 = B.C. 4000-Jan-01.4999999
B.C.  4000-01-01 11:59:59.99 = B.C.  4000-01-01.4999999
B.C.   4000--001 11:59:59.99 = B.C.   4000--001.4999999

Day-of-Week: Thursday

<b>Julian Date</b>
------------------
 260423.9999999 UT
</pre>
=end comment

if not @*ARGS {
    say qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go | raku [debug]

    Extracts data from file:

        $ifil

    and creates draft test files at:

        $ofil2
        $ofilrd
    HERE
    exit;
}

my $raku  = 0;
my $debug = 0;
for @*ARGS {
    when /:i ^d/ { $debug = 1 }
    when /:i ^r/ { $raku  = 1 }
}

# collect the test data
my $in-block = 0;
my $t; # class T object
my @T;
for $ifil.IO.lines {
    # parse data as triplets:
    #   ad|bc    date...
# B.C.  4000-01-01 11:59:59.99 = B.C.  4000-01-01.4999999
    #   day of week
# Day-of-Week: Thursday
    #   julian day
# 260423.9999999 UT
    when /'<pre>'/ {
        $in-block = 1;
        $t = T.new;
    }
    when /'</pre>'/ {
        $in-block = 0;
        # wrap it up
        if $t {
            # assemble the dt value
            my $e = $t.era < 0 ?? '-' !! '+';
            $t.dts = "{$e}{$t.date}T{$t.time}Z";
            @T.push: $t if $t;
        }
    }

    # B.C.   4000--001 11:59:59.99 = B.C.   4000--001.4999999
    when /^ \h* ['B.C.'|'A.D.']
            \h\h\h # <== the THREE spaces are critical for detecting the desired date format
                [\S+] \h+ [\S+] \h+ '=' 
            \h+ ['B.C.'|'A.D.'] \h+
                (\S+) \h* 
         / {
        my $date = ~$0;
        if $date ~~ /^ \d\d\d\d '--'  (\d\d\d) ('.' \d+) $/ {
            say "DEBUG: date = '$date'" if $debug;
            my $doy = ~$0;
            $t.day-frac = +$1;
            $doy ~~ s:g/^0*//;
            $t.doy = $doy;
            say "  doy = '$doy'" if $debug;
            say "  day-frac = '{$t.day-frac}'" if $debug;
        }
        else {
            die "Unexpected date value '$date'";
        }
    }

    # B.C.  4000-01-01 11:59:59.99 = B.C.  4000-01-01.4999999
    when /^ \h* ('B.C.'|'A.D.')
            \h\h # <== the TWO spaces are critical for detecting the desired date format
                (\S+) \h+ (\S+) \h+ '=' 
         / {
        my $era   = ~$0;
        my $date  = ~$1;
        my $time  = ~$2;
        # a hack
        if $date ~~ /^ (\d\d\d\d) '-' \d\d '-' \d\d $/ {
            $t.year  = +$0;
        }
        else {
            die "Unexpected date value '$date'";
        }

        if $era eq 'B.C.' {
            $t.era   = -1;
            $t.year *= -1;
        }
        elsif $era eq 'A.D.' {
            $t.era = 1;
        }
        else {
            die "Unexpected era value '$era'";
        }
        $t.date = $date;
        $t.time = $time;
    }
    when /^ \h* 'Day-of-Week:' \h+ (\S+) / {
        # Day-of-Week: Thursday
        my $dow = ~$0;
        $t.dow  = $dow;
        $t.day-of-week = get-dow-number $dow;
    }
    when /^ \h* (\d+ '.' \d+) \h+ UT/ {
        # 260423.9999999 UT
        my $jd = +$0;
        $t.jd  = $jd;
    }
}

if $debug {
    for @T -> $t {
        say "=== Era: {$t.era}"; # {$t.date}{$t.time}{$t.dow}{$t.jd}"
        say "  {$t.date}"; #{$t.time}{$t.dow}{$t.jd}"
        say "  {$t.time}"; #{$t.dow}{$t.jd}"
        say "  {$t.dow}"; #{$t.jd}"
        say "  {$t.jd}";
        say "  {$t.dts}";
    }
}

my @ofils;

my $fh = open $ofil2, :w;
@ofils.push: $ofil2;
gen-test2 $fh, @T, :$debug;

if $raku {
    $fh = open $ofilr, :w;
    @ofils.push: $ofilr;
}
else {
    $fh = open $ofilrd, :w;
    @ofils.push: $ofilrd;
}
gen-raku-test $fh, @T, :$debug;

say "Normal end.";
my $s = @ofils.elems > 1 ?? 's' !! '';
say "See output file$s:";
say "  $_" for @ofils;

sub get-dow-number($dow) {
    given $dow {
        when /:i ^ \h* mon/ { 1 }
        when /:i ^ \h* tue/ { 2 }
        when /:i ^ \h* wed/ { 3 }
        when /:i ^ \h* thu/ { 4 }
        when /:i ^ \h* fri/ { 5 }
        when /:i ^ \h* sat/ { 6 }
        when /:i ^ \h* sun/ { 7 }
        default {
            die "FATAL: Unknown day-of-week named '$_'";
        }
    }
}

sub gen-test2($fh, @T, :$debug) {
    # this will have to be increased as more tests are added:
    my $ntests = 2 * @T.elems;
    $fh.say: qq:to/HERE/;
    use Test;
    use DateTime::Julian :formatter;
    use DateTime::Julian::APC :ALL;

    plan $ntests;

    my \%jpl =
        # using test data from the JPL website:
        #     https://ssd.jpl.nasa.gov/tc.cgi
    HERE
    for @T -> $t {
        # for now skip negative years
        #next if $t.year < 1855;
        next if $t.year < 0;
        $fh.say: "    '{$t.dts}' => [{$t.jd}, '{$t.dow}', {$t.day-of-week} ],";
    }
    $fh.say: ";\n";

    $fh.say: q:to/HERE/;
    for %jpl.keys.sort -> $ut {
        # with key and value JPL test data
        my $jdin     = %jpl{$ut}[0];
        my $dowin    = %jpl{$ut}[1];
        my $downumin = %jpl{$ut}[2];
        my $dtin     = DateTime.new: $ut, :$formatter;
        #my $mjdin    = cal2mjd :year($dtin.year), :month($dtin.month), :day($dtin.day),
        #                       :hour($dtin.hour), :minute($dtin.minute), :second($dtin.second);
        my $mjdin    = jd2mjd $jdin;
        my $mjdinint = $dtin.daycount;

        # for now check that our 'daycount' agrees with JPL
        $mjdin .= floor;
        is $mjdin, $mjdinint;
        next;

        # the local tests:
        my $dtout = jd2dt :jd($jdin);
        is $dtout.day-of-week, $downumin, "dowin: $dowin $downumin out: {$dtout.day-of-week}";

        # compare jds
        my $mjdout   = cal2mjd :year($dtin.year), :month($dtin.month), :day($dtin.day),
                               :hour($dtin.hour), :minute($dtin.minute), :second($dtin.second);
        my $jdout = mjd2jd $mjdout;
        #$jdout .= round(0.7);

        #is $jdout, $jdin, "jd in: $jdin out: $jdout";
        is-approx $jdout, $jdin, "jd in: $jdin out: $jdout";

        =begin comment
        my $dtout = DateTime::Julian.new: :juliandate($jd), :$formatter;
        is $dtin, $dtout;
        =end comment

        =begin comment
        my $jd2dt = jd2dt :jd($jd);
        my $mjd = cal2mjd :year(self.year), :month(self.month), :day(self.day),
                      :hour(self.hour), :minute(self.minute), :second(self.second);
        =end comment

        =begin comment
        method new(:$juliandate) {
            my $dt = jd2dt :jd($jd);
            self.DateTime::new(
            :year($dt.year), :month($dt.month), :day($dt.day),
                      :hour($dt.hour), :minute($dt.minute), :second($dt.second));
        }
        submethod TWEAK() {
            my $mjd = cal2mjd :year(self.year), :month(self.month), :day(self.day),
                      :hour(self.hour), :minute(self.minute), :second(self.second);
            my $jd = mjd2jd $mjd;
            $!juliandate = $jd;
        }
        my $ut-dt = DateTime::Julian.new: $ut;
        my $jd-dt = DateTime::Julian.new: :juliandate($jd);
        is $ut-dt, $jd-ut;
        =end comment
    }
    HERE

    $fh.close;
} # end sub gen-test2

sub gen-raku-test($fh, @T, :$debug) {
    # this will have to be changed to the final value as tests are stabilized
    constant MJD-offset = 2_400_000.5;
    my $ntests = 126;
    $fh.say: qq:to/HERE/;
    use Test;

    plan $ntests;

    my \%jpl =
        # using test data from the JPL website:
        #     https://ssd.jpl.nasa.gov/tc.cgi
    HERE
    for @T -> $t {
        # the current Raku doesn't handle negative MJDs
        next if $t.jd < MJD-offset;
        $fh.say: "    '{$t.dts}' => [{$t.jd}, '{$t.dow}', {$t.day-of-week}, {$t.day-frac}, {$t.doy} ],";
    }
    $fh.say: ";\n";

    $fh.say: q:to/HERE/;

    # the difference between MJD and JD
    constant MJD-offset = 2_400_000.5;

    for %jpl.kv -> $JPL-utc, $JPL-out {
        # get all the data of interest in desired formats
        my $JPL-jd      = $JPL-out[0];
        my $JPL-jdday   = $JPL-jd.truncate;
        my $JPL-mjd     = $JPL-jd - MJD-offset;
        my $JPL-mjdday  = $JPL-mjd.truncate;
        my $JPL-dow     = $JPL-out[2];
        my $JPL-mjdfrac = frac $JPL-mjd;
        my $JPL-dayfrac = $JPL-out[3];
        my $JPL-doy     = $JPL-out[4];

        # get our data from the input utc as a DateTime object
        my $dt       = DateTime.new: $JPL-utc;
        my $mjd      = $dt.modified-julian-date;
        my $jd       = $dt.julian-date;
        my $day-frac = $dt.day-fraction;
        my $mjdday   = $dt.daycount;
        my $dow      = $dt.day-of-week;
        my $doy      = $dt.day-of-year;

        # check integral values
        is $mjdday, $JPL-mjdday, "cmp MJD.Int: got ($mjdday) vs exp ($JPL-mjdday)";
        is $dow, $JPL-dow, "cmp day-of-week: got ($dow) vs exp ($JPL-dow)";
        is $doy, $JPL-doy, "cmp day-of-year: got ($doy) vs exp ($JPL-doy)";

        # check decimal values for MJD and JD
        my $np-JPL-mjd     = ndp $JPL-mjd;
        my $np-JPL-jd      = ndp $JPL-jd;
        my $np-JPL-mjdfrac = ndp $JPL-mjdfrac;
        my $np-JPL-dayfrac = ndp $JPL-dayfrac;

        $mjd      = sprintf '%.*f', $np-JPL-mjd, $mjd;
        $jd       = sprintf '%.*f', $np-JPL-jd, $jd;
        $day-frac = sprintf '%.*f', $np-JPL-mjdfrac, $day-frac;

        is $mjd, $JPL-mjd, "cmp MJD: got ($mjd) vs exp ($JPL-mjd)";
        is $jd, $JPL-jd, "cmp JD: got ($jd) vs exp ($JPL-jd)";
        is $day-frac, $JPL-mjdfrac, "cmp day-fraction: got ($day-frac) vs exp ($JPL-mjdfrac)";
        is $day-frac, $JPL-dayfrac, "cmp day-fraction: got ($day-frac) vs exp2 ($JPL-dayfrac)";
    }

    # Two subs needed for stand-alone testing with no external dependencies
    # (both are from Math::FractionalPart):
    sub frac($x) {
        $x - floor($x)
    }
    sub ndp($x) {
        my $f = frac $x;
        $f == 0 ?? 0
                !! ($f.chars-2)
    }
    HERE

    $fh.close;
} # sub gen-raku-test


=finish

sub gen-test3($fh, @T, :$debug) {
    # this will have to be increased as more tests are added:
    my $ntests = @T.elems;
    $fh.say: qq:to/HERE/;
    use Test;
    use DateTime::Julian :ALL;

    plan $ntests;

    # test data from JPL
    #   see:  https://ssd.jpl.nasa.gov/tc.cgi
    my \%jpl =
        # using test data from the JPL website:
        #     https://ssd.jpl.nasa.gov/tc.cgi
    HERE
    for @T -> $t {
        $fh.say: "    '{$t.dts}' => [{$t.jd}, '{$t.dow}'],";
    }
    $fh.say: ";\n";

    $fh.say: q:to/HERE/;
    for %jpl.keys.sort -> $ut {
        # with key and value JPL test data:
        my $jd  = %jpl{$ut}[0];
        my $dow = %jpl{$ut}[1];

        my $ut-dt = DateTime::Julian.new: $ut;
        my $jd-dt = DateTime::Julian.new: :juliandate($jd);
        is $ut-dt, $jd-ut;
    }
    HERE

    =begin comment
    my ($year, $month, $day, $hour, $minute, $second) =
        $utin.year, $utin.month, $utin.day, $utin.hour, $utin.minute, $utin.second;
    # convert day/hour/minute/second to day.decimalhms
    my $decimalday = hms2days $hour, $minute, $second;
    $decimalday += $day;
    my $jd = utc2jd $year, $month, $decimalday;

    # how many decimal places?
    my $nplaces = nplaces $jdexp;
    # round output to same number decimal places
    my $jdround = $jd;
    if $nplaces {
        $jdround = sprintf '%0.*f', $nplaces, $jd;
    }
    is $jdround, $jdexp, 'convert UT to JD';
    =end comment
}

# reverse to test the key/values to ensure they round trip okay
my %jd = %utc.invert;

for %jd.keys.sort -> $jd {
    my $jdin  = $jd;
    my $utexp = %jd{$jd};
    my ($year, $month, $day, $hr) = jd2utc $jd;

    # convert decimal hours to hms format
    my ($hour, $minute, $second) = hours2hms $hr;

    # get a DateTime object
    my $ut = DateTime.new: :$year, :$month, :$day, :$hour, :$minute, :$second;
    is $ut.Str, $utexp.Str, 'convert JD to UT';
}
