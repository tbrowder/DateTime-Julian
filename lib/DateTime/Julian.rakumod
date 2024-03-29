unit class DateTime::Julian is DateTime;

use Math::Trig:auth<zef:tbrowder> :ALL;
use Astro::Utils :ALL;

# The last day the Julian calendar was used:
constant JCE            is export = DateTime.new: :1582year, :10month, :4day;
constant jce            is export = JCE;

# The official start date for the Gregorian calendar
# was October 15, 1582. The days of 5-14 were skipped (the 10 "lost days").
constant GC0            is export = DateTime.new: :1582year, :10month, :15day;
constant gc0            is export = GC0;

constant POSIX0         is export = 2_440_587.5; # JD in Gregorian calendar (1970-01-01T00:00:00Z)
constant posix0         is export = POSIX0;

constant MJD0           is export = 2_400_000.5; # JD in Gregorian calendar (1858-11-17T00:00:00Z)
constant mjd0           is export = MJD0;

constant sec-per-day    is export = 86_400;
constant sec-per-cen    is export = 3_155_760_000; # a Julian century
constant days-per-jcen  is export = 36_525;        # a Julian century
constant days-per-jcent is export = 36_525;        # a Julian century
constant days-per-cen   is export = 36_525;        # a Julian century

constant J2000          is export = 2_451_545;     # JD for 2000-01-01T12:00:00Z (astronomical epoch 2000.0)
constant j2000          is export = J2000;

constant J1900          is export = 2_415_020;     # JD for 1899-12-31T12:00:00Z (astronomical epoch 1900.0)
constant j1900          is export = J1900;

constant solar2sidereal is export = 1.002_737_909_350_795 ; # Difference between Sidereal and Solar hour (the former is shorter)

method new(:$julian-date, :$modified-julian-date, |c) {
    # Convert the input value to the suitable POSIX value
    # to instantiate the DateTime object.
    my $JD;
    if $julian-date.defined {
        $JD = $julian-date
    }
    elsif $modified-julian-date.defined {
        # Use relationship: MJD = JD - MJD0 => JD = MJD + MJD0
        $JD = $modified-julian-date + MJD0
    }
    else {
        return self.DateTime::new(|c); # a normal instantiation is expected, otherwise an exception is thrown
    }

    # Given the Julian Date (JD) of an instant, determine its Gregorian UTC
    my $days = $JD - POSIX0;        # days from the POSIX epoch to the desired JD
    my $psec = $days * sec-per-day; # days x seconds-per-day

    # from @lizmat, IRC #raku, 2021-03-29  11:50
    self.DateTime::new($psec); # The desired Gregorian UTC

}

method jdcent2000(--> Real:D) {
    # Returns time as the number of Julian centuries since epoch
    # J2000.0 (time value used by Montenbruck for planet
    # position calculations).
    (self.julian-date - J2000)/days-per-jcen
}
# aliases for the above
method jcent2000(--> Real:D) { self.jdcent2000 }
method cent2000(--> Real:D)  { self.jdcent2000 }
method c2000(--> Real:D)     { self.jdcent2000 }
method jdc2000(--> Real:D)   { self.jdcent2000 }
method t2000(--> Real:D)     { self.jdcent2000 }
method jc2000(--> Real:D)    { self.jdcent2000 }

method jd0(--> Real) {
    # calculate the JD for January 0.0 of the current year
    # see Montenbruck, p. 40
    
}

method gmst(--> Real) {
    # calculate Greenwich Mean Sidereal Time (GMST)
    # return as decimal hours in the range [-12..12]
    # see Montenbruck, p. 40
    constant pi2 = pi/2;

    my \mjd  = self.modified-julian-date;
    my \mjd0 = self.modified-julian-date.floor;
    my \UT   = self.day-fraction;
    my \T0   = (mjd0 - 51544.5)/days-per-jcent;
    my \T    = (mjd  - 51544.5)/days-per-jcent;
    my \GMST = 24110.5481 + 8640184.812866 * T0 + 1.0027379093 * UT
               + (0.093104 - 6.2e-6 * T) * T * T;    # seconds
    (pi2 / sec-per-day) * (GMST % sec-per-day);      # radians
}

method lst(Real \lon,             # decimal degrees
          :$east-positive = True, # some using programs may have west longitudes positive
                                  # (e.g., Meeus, Astro::Montenbruck)
          --> Real) {
    # calculate Local Sidereal Time (LST)
    # see Montenbruck, p. 41
}

method ephemeris-time(--> Real) {
    # using code from Perl Astro::Montenbruck
    #   file ''

    
}


