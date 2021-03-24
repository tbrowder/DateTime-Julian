#!/usr/bin/env raku

my $ifil = 'jpl-test-data.dat';
my $ofil = '02-jpl-time-tests.t';

class T {
    has $.era  is rw;
    has $.date is rw;
    has $.time is rw;
    has $.dow  is rw;
    has $.jd   is rw;
    has $.dt   is rw; # the DateTime.Str repr
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

    and creates a draft test file at:

        $ofil
    HERE
    exit;
}

my $debug = 0;
for @*ARGS {
    when /:i ^d/ { $debug = 1 }
}

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
            $t.dt = "{$e}{$t.date}T{$t.time}Z";
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
        say "  {$t.dt}";
    }
}

my $fh = open $ofil, :w;
gen-test $fh, @T, :$debug;

say "Normal end. See test file '$ofil'.";

sub gen-test($fh, @T, :$debug) {

    my $ntests = @T.elems;

    $fh.say: qq:to/HERE/;
    use Test;
    use DateTime::Julian :ALL;

    plan $ntests;

    my \%jpl =
        # tests from the JPL website:
        #     https://ssd.jpl.nasa.gov/tc.cgi
    HERE

    for @T -> $t {
        $fh.say: "    '{$t.dt}' => [{$t.jd}, '{$t.dow}'],";
    }
    $fh.say: ";";

    $fh.say: q:to/HERE/;
    for %jpl.keys.sort -> $ut {
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