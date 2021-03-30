#!/usr/bin/env raku

my $ifil  = 'jpl-test-data.dat';
my $ofil2 = '02-APC-jpl-time-tests.t';
my $ofil3 = '03-DateTime-Julian-jpl-time-tests.t';

class T {
    has $.era  is rw;
    has $.date is rw;
    has $.time is rw;
    has $.dow  is rw; # Monday, Tuesday, etc.
    has $.jd   is rw;
    has $.dts  is rw; # the DateTime.Str repr
    has $.day-of-week is rw; # DateTime number (Mon = 1, Sun = 7)
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
    Usage: {$*PROGRAM.basename} go [debug]

    Extracts data from file:

        $ifil

    and creates draft test files at:

        $ofil2
        $ofil3
    HERE
    exit;
}

my $debug = 0;
for @*ARGS {
    when /:i ^d/ { $debug = 1 }
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
        if $t {
            # assemble the dt value
            my $e = $t.era < 0 ?? '-' !! '+';
            $t.dts = "{$e}{$t.date}T{$t.time}Z";
            @T.push: $t if $t;
        }
        $t = T.new;
    }
    when /'</pre>'/ { 
        $in-block = 0;
    }
    when /^ \h* ('B.C.'|'A.D.') \h\h (\S+) \h+ (\S+) \h+ '=' / {
        # B.C.  4000-01-01 11:59:59.99 = B.C.  4000-01-01.4999999
        my $era  = ~$0;
        my $date = ~$1;
        my $time = ~$2;
        if $era eq 'B.C.' {
            $t.era = -1;
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

my $fh2 = open $ofil2, :w;
@ofils.push: $ofil2;
gen-test2 $fh2, @T, :$debug;

my $fh3 = open $ofil3, :w;
@ofils.push: $ofil3;
gen-test3 $fh3, @T, :$debug;

say "Normal end.";
my $s = @ofils.elems > 1 ?? 's' !! '';
say "See output file$s:";
say "  $_" for @ofils;

sub get-dow-number($dow) {
    given $dow {
        when /:i ^mon/ { 1 }
        when /:i ^tue/ { 2 }
        when /:i ^wed/ { 3 }
        when /:i ^thu/ { 4 }
        when /:i ^fri/ { 5 }
        when /:i ^sat/ { 6 }
        when /:i ^sun/ { 7 }
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
        my $mjdin    = cal2mjd :year($dtin.year), :month($dtin.month), :day($dtin.day), 
                               :hour($dtin.hour), :minute($dtin.minute), :second($dtin.second);

        # the local tests:
        my $dtout = jd2dt :jd($jdin);
        is $dtout.day-of-week, $downumin, "dowin: $dowin $downumin out: {$dtout.day-of-week}";
        # compare jds
        my $mjdout   = cal2mjd :year($dtin.year), :month($dtin.month), :day($dtin.day), 
                               :hour($dtin.hour), :minute($dtin.minute), :second($dtin.second);
        my $jdout = mjd2jd $mjdout;
        is $jdout, $jdin, "jd in: $jdin out: $jdout";

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
}
sub gen-test3($fh, @T, :$debug) {
    # this will have to be increased as more tests are added:
    my $ntests = @T.elems;
    $fh.say: qq:to/HERE/;
    use Test;
    use DateTime::Julian :ALL;

    plan $ntests;

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

=finish

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
