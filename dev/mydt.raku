#!/usr/bin/env raku


use lib <../lib>;
use DateTime::Julian::APC :ALL;
class Foo is DateTime {
    has $.juliandate;

    method new(:$juliandate) {
        my $dt = jd2dt :jd($juliandate);
        self.DateTime::new(
        :year($dt.year), :month($dt.month), :day($dt.day), 
                  :hour($dt.hour), :minute($dt.minute), :second($dt.second));
    }
    submethod TWEAK() {
        my $mjd = cal2mjd :year(self.year), :month(self.month), :day(self.day), 
                  :hour(self.hour), :minute(self.minute), :second(self.second);
        my $jd = mjd2jd $mjd;
        $!juliandate = $jd;
    }
    method juliandate {
        $!juliandate
    }
    =begin comment
    submethod TWEAK {
        # now we use jdate or mjdate as needed
        # to set the DateTime attributes from the Julian date input
        my $dt = DateTime.now;
        self.year   = $dt.year;
        self.month  = $dt.month;
        self.day    = $dt.day;
        self.hour   = $dt.hour;
        self.minute = $dt.minute;
        self.second = $dt.second;
    }
    =end comment
}

=begin comment
my $jd = 2400000.5;
say "input jd: $jd";

my $ft = Foo.new: :juliandate($jd);
say $ft.raku;
say $ft.juliandate.raku;
my $ojd = $ft.juliandate;
say "output jd: $ojd";
=end comment

# date/jd pairs
my %t = 
   '-4000-01-01T11:59:59.99' => 260423.9999999,
    '2000-01-01T11:59:59.99' => 2451544.9999999,
;

use Test;
for %t.kv -> $utc, $jdin {
    my $dt = DateTime.new: $utc;
    say "utc in: {$utc}";
    say "dt  in: {$dt.utc}";

    my $mjdin = jd2mjd $jdin;

    my $mjdout = cal2mjd :year($dt.year), :month($dt.month), :day($dt.day), 
              :hour($dt.hour), :minute($dt.minute), :second($dt.second);
    my $jdout = mjd2jd $mjdout;
    say "mjdin: $mjdin => mjdout: $mjdout";
    say " jdin: $jdin  =>  jdout: $jdout";
}


=finish

