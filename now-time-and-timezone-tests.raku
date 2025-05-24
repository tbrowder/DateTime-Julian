#!/usr/bin/env raku

# runs various time scenarios
my $n = DateTime.now;
my $z = $n.julian-date;

my $t;
my $tz;
my $tj;
for -1..1 -> $timezone is copy {
    $timezone *= 3600;
    $tz = DateTime.new(now, :$timezone);
    $z  = $tz.utc;
    $tj = $tz.julian-date;
    say "timezone: $timezone";
    say "    $tz"; 
    say "    $z"; 
    say "    $tj";    
}

