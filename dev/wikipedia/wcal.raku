#!/usr/bin/env raku

# using algorithms from the Wikipedia article
# on Julian Date

use lib <../lib>;
use Gen-Test :meeus;

my $ifil = '../meeus/test-data.txt';

my $debug  = 0;
my $julian = 0;
my $test   = 0;
if not @*ARGS {
    say qq:to/HERE/;
    Ugage: {$*PROGRAM.basename} test | yyyy/mm/dd | JD [julian] [debug]

    Uses Wkipedia's algorithms for JD / Cal calculations.

    Uses the Gregorian calendar unless the 'julian' option is entered.

    Able to test the algorithms against Meeus' data in file:
        $ifil

    HERE
   
    exit;
}

my $jd;
my ($ye, $mo, $da);
for @*ARGS {
    when /^:i d/ {++$debug}
    when /^:i j/ {++$julian}
    when /^:i t/ {++$test}
    when /^ ('-' ? \d+) \D+ (\d+) \D+ (\d+ ['.' \d+]?) $/ {
        $ye = +$0;
        $mo = +$1;
        $da = +$2;
    }
    when /^ (\d+ ['.' \d+]?) $/ {
        $jd = +$0;
    }
    default {
        die "FATAL: Unknown arg '$_'";
    }
}
my $gregorian = not $julian;

if $test {
    test-wiki
}
elsif $jd.defined {
    ($ye, $mo, $da) = jd2cal $jd, :$gregorian, :$debug;
    say "For input JD = $jd, Gregorian = $gregorian, y/m/d = $ye $mo $da";
}
elsif $ye.defined {
    $jd = cal2jd $ye, $mo, $da, :$gregorian, :$debug;
    say "For input y/m/d = $ye/$mo/$da, Gregorian = $gregorian, JD = $jd";
}

##### subroutines #####
sub test-wiki(:$gregorian = True, :$debug) {
    my @M = get-meeus-test-data $ifil, :$debug;
    say "Meeus test data (proleptic Gregorian calendar):";
    for @M -> $t {
        say "    Meeus: JD '{$t.jd}' ({$t.jd.Int}) <=> y/m/d '{$t.year}/{$t.m}/{$t.d}' ({$t.d.Int}), '{$t.M.tc}'";
        my $Da = $t.d.Int;
        my $jd = cal2jd $t.year, $t.m, $Da, :$gregorian, :$debug;
        say "        For input y/m/d, JD = $jd";
next;

        my ($ye, $mo, $da) = jd2cal $t.jd.Int, :$gregorian, :$debug;
        say "        For input JD, y/m/d = '$ye/$mo/$da'";
    }
} # sub test-claus

sub cal2jd($ye, $mo, $Da, :$gregorian = True, :$debug) {
    # Tonderling expects an Int
    my $da = $Da.Int;
    my $frac = $Da - $da;

    my \a = floor (14 - $mo)/12;
    my \y = $ye + 4800 - a;
    my \m = $mo + 12 * a - 3;

    my \J = $da + floor((153 * m + 2)/5) + 365 * y + floor(y/4);
    my $jd = $gregorian ?? (J - floor(y/100) + floor(y/400) - 32045)
                        !! (J - 32083);
    # quote "JD is the Julian Day that starts at noon on the specified date."
    return $jd;
} # sub cal2jd

sub jd2cal($Jd, :$gregorian = True, :$debug --> List) {
    my ($ye, $mo, $da);
}
