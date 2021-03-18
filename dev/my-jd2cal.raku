#!/usr/bin/env raku

constant DJD_TO_JD = 2415020;

my %t = 
# jd => y, m, d, h
-0.5 => [-4713, 1, 1, 0],
-1.0 => [-4714, 12, 31, 12],
0 => [-4713, 1, 1, 12],
1.1 => [],
1.3 => [],
1.7 => [],
1.9 => [],
;

if not @*ARGS {
    say "Usage: {$*PROGRAM.basename} go";
    exit;
}

for %t.keys.sort -> $jd {
    my $res = %t{$jd};
    my ($y, $m, $d, $h) = jd2cal $jd;
    say();
    say "jd: $jd, y/m/d/h = $y $m $d $h";
    say $res.raku;
    my $fni = fni $jd;
    my $fnl = fnl $jd;
    say "fni = $fni";
    say "fnl = $fnl";
    my $fni2 = $jd.Int;
    #my $fnl2 = $jd.ceiling;
    my $fnl2 = $jd.floor;
    say "fni2 = $fni2";
    say "fnl2 = $fnl2";


}

# function Int?
sub fni ( $x ) {
    return sign($x) * truncate(abs($x));
}

# least-integer function
# function ceiling?
sub fnl( $x ) {
    return fni($x) + fni((sign($x) - 1.0) / 2.0);
}

sub jd2cal( $jd ) {
    my $dj = $jd - DJD_TO_JD;
    my $d = $dj + 0.5;
    my $i = fnl($d);
    my $fd = $d - $i;

    # If time is 24:00 then increment day
    if ($fd == 1) {
        $fd = 0;
        $i++;
    }
    # Deal with Gregorian change
    if ($i > -115860) {
        my $a = fnl( ($i / 36524.25) + 9.9835726E-1) + 14;
        $i += 1 + $a - fnl($a / 4);
    }
    my $b = fnl($i / 365.25 + 8.02601e-1);
    my $c = $i - fnl(365.25 * $b + 7.50001e-1) + 416;
    my $g = fnl($c / 30.6001);
    my $dh = $c - fnl(30.6001 * $g) + $fd;
    my $mo = $g - ($g > 13.5 ?? 13 !! 1);
    my $ye = $b + ($mo < 2.5 ?? 1900 !! 1899);
    # convert astronomical, zero-based year to civil
    if ($ye < 1) {
      $ye--;
    }
    my $hm = ($dh - truncate($dh)) * 24.0;
    my $da = truncate($dh);
    return ($ye, $mo, $da, $hm);
}

=finish

sub MAIN( $jd ) {
    say "JD: $jd";
    my ($y, $m, $d, $h) = jd2cal($jd);
    say "$y $m $d $h";
}


=begin comment

# email test

Here is my first Raku script. It converts Julian dates to civil. 
I have borrowed the method from "Astronomy with Your PC"
by Peter Duffett-Smith, 1990. Very valuable source, except that the 
code examples are in ancient dialect of Basic, with goto-s and line numbers.

At the first glance, the results for negative Julian dates make sense.

JD: 0
-4713 1 1 12
JD: -0.5
-4713 1 1 0
JD: -1.0
-4714 12 31 12

What's interesting, neither native 'ceiling(), nor 'truncate()' give correct results, 
although 'ceiling' is called 'least integer function'.

Do you use the recommended Comma IDE for Raku? I don't feel comfortable with it, 
maybe because I have not used any of IntelliJ products.

=end comment
