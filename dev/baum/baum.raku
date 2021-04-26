#!/usr/bin/env raku
#
use Text::Utils :strip-comment;

use lib <../lib ./.>;

my $ifil  = 'baum-test-data.txt';
my $ofil  = 'baum-data.t';
my $debug = 0;
my $greg-only = 1;
if not @*ARGS {
    say qq:to/HERE/;
    Ugage: {$*PROGRAM.basename} go [debug]

    Tests DateTime against Baum's Gregorian date test data in
    file '$ifil'.

    For now only the Gregorian dates are tested.

    HERE

    exit;
}

for @*ARGS {
    when /^:i d/ {++$debug}
}

my @t;
my $nd = 0;
for $ifil.IO.lines -> $line is copy {
    $line = strip-comment $line;
    next if $line !~~ /\S/;
    note "DEBUG: line: '$line'" if $debug;
    ++$nd;
    my @w = $line.words;
    my $j = @w.shift;
    my $y = @w.shift;
    my $m = @w.shift;
    my $d = @w.shift;
    my $gregorian = True;
    if @w.elems {
        my $s = @w.shift;
        $gregorian = False if $s ~~ /^:i j/;
        note "DEBUG: gregorian = '{$gregorian}'" if $debug;
    }
    next if $greg-only and not $gregorian;

    note "    DEBUG: y/m/d (Gregorian == $gregorian) => jd : $y $m $d => $j" if $debug;

    # load the test array with the test data
    @t.push: [$y, $m, $d, $j, $gregorian];
}
say "Found $nd data points.";

my $fh = open $ofil, :w;
my $ndp = @t.elems;
$fh.print: qq:to/HERE/;
use Test;
use lib <../lib ./.>;
use Baum;

plan 183;

my \@baum-test-data = [
    # $ndp data points
    # Gregorian date   Julian date
    #    Y   M  D        JD
HERE

for @t -> $arr {
    my @v = @($arr);
    $fh.say: "    [{@v[0]}, {@v[1]}, {@v[2]}, {@v[3]}],";
}

$fh.say: q:to/HERE/;
];

my $tnum = 0;

# The official start date for the Gregorian calendar
# was October 15, 1582.
constant GC = DateTime.new: :1582year, :10month, :15day;
constant POS0 = 2440587.5; # JD in Gregorian calendar (1970-01-01T00:00:00Z)
constant MJD0 = 2400000.5; # JD in Gregorian calendar (1858-11-17T00:00:00Z)
constant sec-per-day = 86400;

for @baum-test-data -> $arr {
    ++$tnum;
    my $ye  = $arr[0];
    my $mo  = $arr[1];
    my $da  = $arr[2]; # a real number
    my $JD  = $arr[3];
    my $gregorian = $arr[4];

    my ($day-frac, $day) = modf $da;
    my ($ho, $mi, $se) = day-frac2hms $day-frac;

    # check the Raku implementations

    # Given the Julian Date (JD) of an instant, determine its Gregorian UTC
    # use the test value $jd
    my $days = $JD - POS0;          # days from the POSIX epoch to the desired JD
    my $psec = $days * sec-per-day;      # days x seconds-per-day
    my $date = DateTime.new($psec); # the desired UTC

    is $date.hour, $ho, "=== data point $tnum: cmp JD to DateTime hour";
    is $date.minute, $mi, "cmp JD to DateTime minute";
    is $date.second, $se, "cmp JD to DateTime second";
    if $gregorian {
        is $date.year, $ye, "cmp JD to DateTime year";
        is $date.month, $mo, "cmp JD to DateTime month";
        is $date.day, $day, "cmp JD to DateTime day";
    }

    # Given a Gregorian instant (UTC), determine its Julian Date (JD)
    if $gregorian {
        my $d   = DateTime.new: :year($ye), :month($mo), :day($day), :hour($ho), :minute($mi), :second($se);

        my $psec = $d.Instant.tai;
        my $pdays = $psec/sec-per-day;
        my $jd = $pdays + POS0;

        =begin comment
        # daycount is bad
        my $mjd = $d.daycount;
        $mjd   += day-frac $d;
        my $jd  = $mjd + MJD0; # from the relationship: MJD = JD - 240000.5
        =end comment

        is-approx $jd, $JD, "cmp JD from DateTime";
    }
}
HERE

$fh.close;
say "See outout file '$ofil'";
