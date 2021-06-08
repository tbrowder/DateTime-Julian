use Test;

use DateTime::Julian;

plan 1;

lives-ok {
    my $d = DateTime::Julian.new(now);
}, "Basic DateTime instantiation";
