unit module Gen-Test;

use Text::Utils :strip-comment;

=begin comment
Note from Wikipedia article:

Both of these dates are years of the Anno Domini or Common Era (which
has no year 0 between 1 BC and AD 1). Astronomical calculations
generally include a year 0, so these dates should be adjusted
accordingly (i.e. the year 4713 BC becomes astronomical year number
-4712, etc.). In this article, dates before 15 October 1582 are in the
(possibly proleptic) Julian calendar and dates on or after 15 October
1582 are in the Gregorian calendar, unless otherwise labelled.
=end comment

class T {...}

sub get-meeus-test-data($ifil, :$debug --> List) is export(:meeus) {
    # returns an array of class T objects

    my @T;
    for $ifil.IO.lines -> $line is copy {
        $line = strip-comment $line;
        next if $line !~~ /\S/;
        note "DEBUG: line: '$line'" if $debug;
        my $t = T.new;
        my @w = $line.words;
        my $y = @w.shift;
        my $M = @w.shift;
        my $m = mon2num $M;
        my $d = @w.shift;
        my $j = @w.shift;    
        note "    DEBUG: y/m/d ($M) => jd : $y $m $d => $j" if $debug;

        #my ($ye, $mo, $da) = jd2cal $j;
        #say "JD $j ($y/$m/$d) => $ye/$mo/$da";
        # load the hash with the test data
        #   %t{$j} = [$y, $m, $d, $M];

        # COMMON attrs
        $t.year = $y;
        $t.jd   = $j; # Julian date (years + fraction of a 24-hour day)

        # Meeus only
        $t.m    = $m; # 1..12
        $t.d    = $d; # 1..31 + fraction of day (of 24 hrs = 86400 sec)
        $t.M    = $M; # Jan..Dec
        @T.push: $t;
    }
    my $nd = @T.elems;
    die "FATAL: Expected 16 data points but got $nd." if $nd != 16;

    return @T;

} # sub get-meeus-test-data

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

sub get-jpl-test-data($ifil, :$debug --> List) is export {
    # returns an array of class T objects

    # from JPL
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
    return @T;
} # sub get-jpl-test-data

# a class for holding time test data from several sources and formats
class T is export(:meeus) {
    # JPL only
    has $.era  is rw; # subtract 1 from dates B.C. from JPL
    has $.date is rw;
    has $.time is rw;
    has $.dow  is rw; # Monday, Tuesday, etc.
    has $.dts  is rw; # the DateTime.Str repr
    has $.day-of-week is rw; # DateTime number (Mon = 1, Sun = 7)
    has $.day-frac is rw;
    has $.doy  is rw; # 1..367

    # COMMON attrs
    has $.year is rw;
    has $.jd   is rw; # Julian date (years + fraction of a 24-hour day)

    # Meeus only
    #%t{$j} = [$y, $m, $d, $M];
    has $.m    is rw; # 1..12
    has $.d    is rw; # 1..31 + fraction of day (of 24 hrs = 86400 sec)
    has $.M    is rw; # Jan..Dec
}

sub get-dow-number($dow) is export {
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

    # mandatory close, caller expects it
    $fh.close;
} # end sub gen-test2

sub mon2num($m) is export(:mon2num) {
    with $m {
        when /^:i jan/ {  1 }
        when /^:i feb/ {  2 }
        when /^:i mar/ {  3 }
        when /^:i apr/ {  4 }
        when /^:i may/ {  5 }
        when /^:i jun/ {  6 }
        when /^:i jul/ {  7 }
        when /^:i aug/ {  8 }
        when /^:i sep/ {  9 }
        when /^:i oct/ { 10 }
        when /^:i nov/ { 11 }
        when /^:i dec/ { 12 }
        default {
            die "FATAL: Unrecognized month named '$m'";
        }
    }
}
