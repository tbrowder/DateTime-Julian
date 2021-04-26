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
    next if not $gregorian and $greg-only;

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
constant pos-ref = 2440587.5; # JD in Gregorian calendar (1970-01-01T00:00:00Z)
constant mjd-ref = 2400000.5; # JD in Gregorian calendar (1858-11-17T00:00:00Z)

for @baum-test-data -> $arr {
    ++$tnum;
    my $ye  = $arr[0];
    my $mo  = $arr[1];
    my $da  = $arr[2]; # a real number
    my $jd  = $arr[3];
    my $gregorian = $arr[4];

    my ($day-frac, $day) = modf $da;
    my ($ho, $mi, $se) = day-frac2hms $day-frac;
 

    # check the Meeus implementations
    my $JD = cal2jd $ye, $mo, $da, :$gregorian;
    my ($Y, $M, $D) = jd2cal $jd, :$gregorian;
    # we may need proleptic Gregorian values from Meeus' data
    my ($JDg, $Yg, $Mg, $Dg);
    if not $gregorian {
        $JDg = cal2jd $ye, $mo, $da, :gregorian(True);
        ($Yg, $Mg, $Dg) = jd2cal $jd, :gregorian(True);
    }

    is $JD, $jd, "== data point $tnum: cmp JD, Gregorian: $gregorian"; 
    is $Y, $ye, "cmp Y, Gregorian: $gregorian";
    is $M, $mo, "cmp M, Gregorian: $gregorian";
    is $D, $da, "cmp D, Gregorian: $gregorian";

    # check the Raku implementations

    # Given the Julian Date (JD) of an instant, determine its Gregorian UTC
    constant POS0 = 2_440_587.5;    # the POSIX epoch in terms of JD
    # use the test value $jd
    my $days = $jd - POS0;          # days from the POSIX epoch to the desired JD
    my $psec = $days * 86_400;      # days x seconds-per-day
    my $date = DateTime.new($psec); # the desired UTC

    is $date.hour, $ho, "cmp JD to DateTime hour";
    is $date.minute, $mi, "cmp JD to DateTime minute";
    is $date.second, $se, "cmp JD to DateTime second";
    if $gregorian {
        is $date.year, $Y, "cmp JD to DateTime year";
        is $date.month, $M, "cmp JD to DateTime month";
        is $date.day, $D.Int, "cmp JD to DateTime day";
    }
    else {
        is $date.year, $Yg, "cmp JD to DateTime year, special handling for pre-Gregorian date";
        is $date.month, $Mg, "cmp JD to DateTime month, special handling for pre-Gregorian date";
        is $date.day, $Dg.Int, "cmp JD to DateTime day, special handling for pre-Gregorian date";
    }

    # Given a Gregorian instant (UTC), determine its Julian Date (JD)
    if $gregorian {
        my $d   = DateTime.new: :year($Y), :month($M), :day($D.Int), :hour($ho), :minute($mi), :second($se);

        my $psec = $d.Instant.tai;
        my $pdays = $psec/86_400;
        my $jd = $pdays + POS0;

        =begin comment
        # daycount is bad
        my $mjd = $d.daycount;
        $mjd   += day-frac $d;
        my $jd  = $mjd + 2_400_00.5; # from the relationship: MJD = JD - 240000.5
        =end comment

        is-approx $jd, $JD, "cmp JD from DateTime";
    }
#=begin comment
    else {
        my $d   = DateTime.new: :year($Yg), :month($Mg), :day($Dg.Int), :hour($ho), :minute($mi), :second($se);

        my $psec = $d.Instant.tai;
        my $pdays = $psec/86_400;
        my $jd = $pdays + POS0;

        =begin comment
        my $mjd = $d.daycount;
        $mjd   += day-frac $d;
        my $jd  = $mjd + 2_400_00.5; # from the relationship: MJD = JD - 240000.5
        =end comment

        is-approx $jd, $JD, "cmp JD, special handling for pre-Gregorian date";
    }
#=end comment
}
HERE

$fh.close;
say "See outout file '$ofil'";
