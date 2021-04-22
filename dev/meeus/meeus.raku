#!/usr/bin/env raku
#
use Text::Utils :strip-comment;

use lib <../lib ./.>;
use Gen-Test :mon2num;
use Meeus;

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
use Test;
use lib <../lib ./.>;
use Meeus;

plan 92;

my \@meeus-test-data = [
    # $ndp data points
    # Julian-date   Y   M  D      m    Gregorian?
HERE

for @t -> $arr {
    my @v = @($arr);
    $fh.say: "    [{@v[0]}, {@v[1]}, {@v[2]}, {@v[3]}, '{@v[4].tc}', {@v[5]}],"; 
}

$fh.say: q:to/HERE/;
];

# use the data and check for round-tripping
my $tnum = 0;
for @meeus-test-data -> $arr {
    ++$tnum;
    my $jd  = $arr[0];
    my $ye  = $arr[1];
    my $mo  = $arr[2];
    my $da  = $arr[3];
    my $mon = $arr[4];
    my $gregorian = $arr[5];

    my $JD = cal2jd $ye, $mo, $da, :$gregorian;
    my ($Y, $M, $D) = jd2cal $jd, :$gregorian;

    is $JD, $jd, "== data point $tnum: cmp JD, Gregorian: $gregorian"; 
    is $Y, $ye, "cmp Y, Gregorian: $gregorian";
    is $M, $mo, "cmp M, Gregorian: $gregorian";
    is $D, $da, "cmp D, Gregorian: $gregorian";
}
HERE


=begin comment
    # define some key epochs
    constant JD 

HERE
=end comment
$fh.close;
say "See outout file '$ofil'";
