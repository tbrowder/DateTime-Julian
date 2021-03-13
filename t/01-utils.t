use Test;
use DateTime::Julian :ALL;

plan 20;

is frac(1.5), 0.5;
is frac(-1.5), 0.5;

my %t =
    0.27     => [6, 28, 48],
    0.271    => [6, 30, 14.4],
    0.2711   => [6, 30, 23.04],
    0.27111  => [6, 30, 23.90],
    0.271111 => [6, 30, 23.99],
    0.78     => [18, 43, 12],
;

for %t.keys.sort -> $k {
    my $v = %t{$k};
    my ($hh, $mm, $ss) = $v;
    my ($h, $m, $s) = dayfrac2hms $k;

    is $h, $hh;
    is $m, $mm;
    is-approx $s, $ss, 0.1;
}
