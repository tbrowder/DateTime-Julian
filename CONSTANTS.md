    # The last day the Julian calendar was used:
    constant JCE is export(:JCE) = DateTime.new: :1582year, :10month, :4day;
    constant jce is export(:jce) = JCE;

    # The official start date for the Gregorian calendar
    # was October 15, 1582. The days of 5-14 were skipped (the 10 "lost days").
    constant GC0 is export(:GC0) = DateTime.new: :1582year, :10month, :15day;
    constant gc0 is export(:gc0) = GC0;

    # JD in Gregorian calendar (1970-01-01T00:00:00Z)
    our constant POSIX0  is export(:POSIX0) = 2_440_587.5; 
    our constant posix0  is export(:posix0) = POSIX0;

    # JD in Gregorian calendar (1858-11-17T00:00:00Z)
    constant MJD0           is export(:MJD0) = 2_400_000.5; 
    constant mjd0           is export(:mjd0) = MJD0;

    constant minutes-per-day is export(:minutes-per-day) = 1_440;
    constant min-per-day     is export(:min-per-day) = 1_440;

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

