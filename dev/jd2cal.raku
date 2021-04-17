#!/usr/bin/env raku
#
use Text::Utils :strip-comment;

use lib <./lib>;
use Gen-Test :mon2num;

my $ifil  = './meeus/test-data.txt';
my $ofil  = './meeus/test-data-hash.txt';
my $debug = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Ugage: {$*PROGRAM.basename} go [debug]

    Tests sub jd2cal against Meeus's test data in
    file '$ifil'.
    HERE
   
    exit;
}

for @*ARGS {
    when /^:i d/ {++$debug}
}

my %t;
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
    note "    DEBUG: y/m/d ($M) => jd : $y $m $d => $j" if $debug;

    my ($ye, $mo, $da) = jd2cal $j;
    say "JD $j ($y/$m/$d) => $ye/$mo/$da";
    # load the hash with the test data
    %t{$j} = [$y, $m, $d, $M];
}
say "Normal end. Found $nd data points (expected 16).";

my $d0 = DateTime.new: :year(-4712), :month(1), :day(1), :hour(12);
my $d1 = DateTime.new: :year(2000), :month(1), :day(1), :hour(12);
my $ds = $d1 - $d0;
my $dd = $ds/86400;
say "does test JD (2451545) == $dd ?";

my $days0 = $d0.daycount;
my $days1 = $d1.daycount;
my $ddays = $days1 - $days0;
say "does test JD (2451545) == $ddays ?";

# output the hash into a txt file
my $fh = open $ofil, :w;
$fh.print: q:to/HERE/;
    my %meeus-test-data = [
HERE

for %t.keys.sort -> $k {
    my @v = @(%t{$k});
    $fh.say: "         $k => [{@v[0]}, {@v[1]}, {@v[2]}, '{@v[3].tc}'],"; 
}

$fh.say: q:to/HERE/;
    ];

    # define some key epochs
    constant JD 

HERE
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

sub jd2cal($jd, :$gregorian = True) {
    # Standard Julian Date for  31.12.1899 12:00 (astronomical epoch 1900.0)
    my constant $J1900 = 2415020;
    my ($f, $i) = modf( $jd - $J1900 + 0.5 );
    note "DEBUG: input to modf: {$jd - $J1900 + 0.5} => \$f ($f), \$i ($i)" if $debug;

    if $gregorian && $i > -115860  {
        my $a = floor( $i / 36524.25 + 9.9835726e-1 ) + 14;
        $i += 1 + $a - floor( $a / 4 );
    }

    my $b  = floor( $i / 365.25 + 8.02601e-1 );
    my $c  = $i - floor( 365.25 * $b + 7.50001e-1 ) + 416;
    my $g  = floor( $c / 30.6001 );
    my $da = $c - floor( 30.6001 * $g ) + $f;
    my $mo = $g - ( $g > 13.5 ?? 13 !! 1 );
    my $ye = $b + ( $mo < 2.5 ?? 1900 !! 1899 );
    # Note $da is a Real number
    $ye, $mo, $da;
}
