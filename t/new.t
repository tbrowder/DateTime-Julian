use Test;

use DateTime::Julian;

plan 3;

# ensure we can use normal DateTime instantiation for its child class
lives-ok {
    my $d = DateTime::Julian.new(now);
}, "Basic DateTime instantiation";

lives-ok {
    my $d = DateTime::Julian.new: :2023year;
}, "Basic DateTime instantiation";

lives-ok {
    my $d = DateTime::Julian.new: "2045-03-09T13:14:09.12345Z";
}, "Basic DateTime instantiation";
