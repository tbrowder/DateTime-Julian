unit class DateTime::Julian is DateTime;

use Math::Trig:auth<zef:tbrowder> :ALL;
use Astro::Utils :ALL;

# The last day the Julian calendar was used:
constant JCE is export(:JCE) = DateTime.new: :1582year, :10month, :4day;
constant jce is export(:jce) = JCE;

# The official start date for the Gregorian calendar
# was October 15, 1582. The days of 5-14 were skipped (the 10 "lost days").
constant GC0 is export(:GC0) = DateTime.new: :1582year, :10month, :15day;
constant gc0 is export(:gc0) = GC0;

# JD in Gregorian calendar (1970-01-01T00:00:00Z)
constant POSIX0  is export(:POSIX0) = 2_440_587.5; 
constant posix0  is export(:posix0) = POSIX0;

# JD in Gregorian calendar (1858-11-17T00:00:00Z)
constant MJD0           is export(:MJD0) = 2_400_000.5; 
constant mjd0           is export(:mjd0) = MJD0;

constant minutes-per-day is export(:minutes-per-day) = 1_440;
constant min-per-day     is export(:min-per-day)     = 1_440;

constant sec-per-day    is export(:sec-per-day) = 86_400;
constant sec-per-cen    is export(:sec-per-cen) = 3_155_760_000; 

# a Julian century
constant days-per-jcen  is export(:days-per-jcen)  = 36_525; 
constant days-per-jcent is export(:days-per-jcent) = 36_525;        
constant days-per-cen   is export(:days-per-cen)   = 36_525;        

# JD for 2000-01-01T12:00:00Z 
# (astronomical epoch 2000.0)
constant J2000          is export(:J2000) = 2_451_545;    
constant j2000          is export(:j2000) = J2000;

# JD for 1899-12-31T12:00:00Z 
# (astronomical epoch 1900.0)
constant J1900          is export(:J1900) = 2_415_020;     
constant j1900          is export(:j1900) = J1900;

# Difference between Sidereal and Solar hour (the former is shorter)
constant solar2sidereal is export(:solar2sidereal) = 1.002_737_909_350_795; 

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
        # a normal instantiation is expected, otherwise an exception is thrown
        return self.DateTime::new(|c); 
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
   # TODO 
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

method lst(
    Real \lon,             # decimal degrees
   :$east-positive = True, # some using programs may have west longitudes positive
                           # (e.g., Meeus, Astro::Montenbruck)
   --> Real) {
    # calculate Local Sidereal Time (LST)
    # see Montenbruck, p. 41
# TODO
}

method ephemeris-time(--> Real) {
    # using code from Perl Astro::Montenbruck
    #   file ''
# TODO

    
}


