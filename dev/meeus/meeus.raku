#!/usr/bin/env raku
#
use Text::Utils :strip-comment;

use lib <../lib>;
use Gen-Test :mon2num;

my $ifil  = 'test-data.txt';
my $ofil  = 'meeus-data.t';
my $debug = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Ugage: {$*PROGRAM.basename} go [debug]

    Tests subs jd2cal and cal2jd against Meeus's test data in
    file '$ifil'.

    NOTE: The 'INT' function described in Meeus is the Raku 'floor' routine.
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
    my $y = @w.shift;
    my $M = @w.shift;
    my $m = mon2num $M;
    my $d = @w.shift;
    my $j = @w.shift;    
    my $gregorian = True;
    if @w.elems {
        my $s = @w.shift;
        $gregorian = False if $s ~~ /^:i j/;
        note "DEBUG: gregorian = '{$gregorian}'" if $debug;
    }

    note "    DEBUG: y/m/d ($M) (Gregorian == $gregorian) => jd : $y $m $d => $j" if $debug;

    my ($ye, $mo, $da) = jd2cal $j, :$gregorian, :$debug;
    say "JD $j ($y/$m/$d) => $ye/$mo/$da";

    # load the test array with the test data
    @t.push: [$j, $y, $m, $d, $M, $gregorian];
}
say "Normal end. Found $nd data points (expected 16).";

my $d0 = DateTime.new: :year(-4712), :month(1), :day(1), :hour(12);
my $d1 = DateTime.new: :year(2000), :month(1), :day(1), :hour(12);
my $ds = $d1 - $d0;
my $dd = $ds/86400;
say "cmp DateTime instants, does test JD days (2451545) == $dd ?";

my $days0 = $d0.daycount;
my $days1 = $d1.daycount;
my $ddays = $days1 - $days0;
say "cmp DateTime daycounts, does test JD (2451545) == $ddays ?";

# output the hash into a txt file
my $fh = open $ofil, :w;
my $ndp = @t.elems;
$fh.print: qq:to/HERE/;
    my \%meeus-test-data = [
        # $ndp data points
        # Julian-date   Y   M  D      m    Gregorian?
HERE

for @t -> $arr {
    my @v = @($arr);
    $fh.say: "        [{@v[0]}, {@v[1]}, {@v[2]}, {@v[3]}, '{@v[4].tc}', {@v[5]}],"; 
}

$fh.say: q:to/HERE/;
    ];
HERE

=begin comment
    # define some key epochs
    constant JD 

HERE
=end comment
$fh.close;
say "See outout file '$ofil'";

##### subs #####

sub modf($x) {
    # splits $x into integer and fractional parts
    # note the sign of $x is applied to BOTH parts
    my $int-part  = $x.Int;
    my $frac-part = $x - $int-part;
    $frac-part, $int-part;
}

sub jd0($year, :$gregorian = True, :$debug) {
    # from p. 62 in 1998 edition
    my \Y = $year - 1;
    my \A = floor(Y/100);
    my $jd0 = floor(365.25 * Y) - A + floor(A/4) + 1_721_424.5;
    $jd0
}

sub cal2jd($y is copy, $m is copy, $d, :$gregorian = True, :$debug --> Real) {
    # from p. 60 in 1998 edition
    if $m == 1 or $m == 2 {
        $y -= 1;
        $m += 12;
    }
    my \Y = $y;
    my \M = $m;
    my \D = $d;

    my $b;
    if $gregorian {
        my $A = floor(Y/100);
        $b = 2 - $A + floor($A/4);
    }
    else {
        $b = 0;
    }
    my \B = $b;

    my \JD = floor(365.25 * (Y + 4_716)) + floor(30.6001 * (M + 1)) + D + B - 1_524.5;
    JD
}

sub jd2cal($jd, :$gregorian = True, :$debug --> List) {
    # from p. 63 in 1998 edition
    # valid only for positive JD

    my ($frac-part, $int-part) = modf($jd + 0.5);
    my \F = $frac-part;
    my \Z = $int-part;

    note "DEBUG: input to modf: {$jd + 0.5} => F ({F}), Z ({Z})" if $debug;

    my $A;
    if Z >= 2_291_161 {
        my $alpha = floor( (Z - 1_867_216.25) / 36_524.25 );
        $A = Z + 1 + $alpha - floor( $alpha / 4 );
    }
    else {
        $A = Z;
    }
    my \A = $A;

    my \B = A + 1524;
    my \C  = floor( (B - 122.1) / 365.25 );
    my \D = floor( 365.25 * C );
    my \E  = floor( (B -D) / 30.6001 );

    my $da = B - D - floor(30.6001 * E) + F;
    my $mo = E - ( E < 14 ?? 1 !! 13 );
    my $ye = C - ( $mo > 2 ?? 4716 !! 4715 );
    
    # Note $da is a Real number
    $ye, $mo, $da;
}
