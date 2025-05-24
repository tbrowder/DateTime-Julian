[![Actions Status](https://github.com/tbrowder/DateTime-Julian/actions/workflows/linux.yml/badge.svg)](https://github.com/tbrowder/DateTime-Julian/actions) [![Actions Status](https://github.com/tbrowder/DateTime-Julian/actions/workflows/macos.yml/badge.svg)](https://github.com/tbrowder/DateTime-Julian/actions) [![Actions Status](https://github.com/tbrowder/DateTime-Julian/actions/workflows/windows.yml/badge.svg)](https://github.com/tbrowder/DateTime-Julian/actions)

DateTime::Julian
================

Provides a DateTime::Julian class (a subclass of Raku's class **DateTime**) that is instantiated by either a Julian Date (JD) or a Modified Julian Date (MJD) (or any of the DateTime instantiation methods).

It also provides addional time data not provided by the core class.

SYNOPSIS
========

```raku
use DateTime::Julian :ALL; # export all constants

my $jd   = nnnn.nnnn; # Julian Date for some event
my $mjd  = nnnn.nnnn; # Modified Julian Date for some event
my $utc  = DateTime::Julian.new: :julian-date($jd);
my $utc2 = DateTime::Julian.new: :modified-julian-date($mjd);
my $d    = DateTime::Julian.now; # the default
```

DESCRIPTION
===========

Module **DateTime::Julian** defines a class (inherited from a Raku *DateTime* class) that is instantiated from a *Julian Date* or a *Modified Julian Date*.

Following are some pertinent definitions from Wikipedia topic [*Julian day*](https://en.m.wikipedia.org/wiki/Julian_day):

  * The **Julian day** is the continuous count of the days since the beginning of the Julian period, and is used primarily by astronomers....

  * The **Julian day number** (JDN) is the integer assigned to a whole solar day count starting from noon Universal time, with Julian day number 0 assigned to the day starting at noon on Monday, January 1, 4713 BC, proleptic [Note 1] Julian calendar (November 24, 4714 BC, in the proleptic Gregorian calendar), a date at which three multi-year cycles started (which are: indiction, Solar, and Lunar cycles) and which preceded any dates in recorded history. For example, the Julian day number for the day starting at 12:00 UT (noon) on January 1, 2000, was **2451545**.

  * The **Julian date** (JD) of any instant is the Julian day number plus the fraction of a day since the preceding noon in Universal Time. Julian dates are expressed as a Julian day number with a decimal fraction added. For example, the Julian date for 00:30:00.0 UT (noon), January 1, 2013, is **2456293.520833**.

The following methods and routines were developed from the descriptions of code in [References 1 and 2](#References). The author of Ref. 3 has been very helpful with this author's questions about astronomy and the implementation of astronomical routines.

The main purpose of this module is to simplify time and handling for this author who still finds Julian dates to be somewhat mysterious, but absolutely necessary for dealing with astronomy and predicting object positions, especially the Sun and Moon, for local observation and producing astronomical almanacs.

This module plays a major supporting role in this author's Raku module **Astro::Almanac**.

Class DateTime::Julian methods
------------------------------

### method new

    new(:$julian-date, :$modified-julian-date) {...}

If both arguments are entered, the *Julian Date* is used. If neither is entered, the user is expected to use one of the normal **DateTime** creation methods. For example:

    my $d = DateTime.now;
    # the Julian Date returned is the current JD at the Prime
    # Meridian (0 degrees longitude) based on the current local time
    # (:timezone is ignored)
    say $d.julian-date; # OUTPUT: «2460819.8055783305␤»

### method jdcent2000

    jdcent2000(--> Real:D) {...}
    # alternatively use aliases:
    method cent2000(--> Real:D)  {...}
    method c2000(--> Real:D)     {...}
    method jdc2000(--> Real:D)   {...}
    method t2000(--> Real:D)     {...}
    method jc2000(--> Real:D)    {...}

Returns time as the number of Julian centuries since epoch J2000.0 (time value used by Astro::Montenbruck for planet position calculations).

Exported constants
------------------

Several commonly used astronautical constants are exported. See a complete list in [CONSTANTS](CONSTANTS.md) along with each constants' individual export tag. You may export them all with `use DateTime::Julian :ALL;`.

### MJD0

Returns the Julian Date value for the Modified Julian Date epoch of 1858-11-17T00:00:00Z.

    use DateTime::Julian :ALL;
    say MJD0;               # OUTPUT: «2400000.5␤»
    # alternatively use aliases:
    say mjd0;               # OUTPUT: «2400000.5␤»

### POSIX0

Returns the Julian Date value for the POSIX (Unix) epoch of 1970-01-01T00:00:00Z.

    say POSIX0;               # OUTPUT: «2440587.5␤»
    # alternatively use alias:
    say posix0;               # OUTPUT: «2440587.5␤»

### JCE

The last day the Julian calendar was used. A DateTime object for 1582-10-04T00:00:00Z.

    say JCE;                 # OUTPUT: «1582-10-04T00:00:00Z␤»
    # alternatively use alias:
    say jce;                 # OUTPUT: «1582-10-04T00:00:00Z␤»

### GC0

The official start date for the Gregorian calendar. A DateTime object for 1582-1014T00:00:00Z. The days of 5-14 were skipped (the 10 "lost days").

    say GC0;                 # OUTPUT: «1582-10-15T00:00:00Z␤»
    # alternatively use alias:
    say gc0;                 # OUTPUT: «1582-10-15T00:00:00Z␤»

### J2000

Julian date for 2000-01-01T12:00:00Z (astronomical epoch 2000.0).

    say J2000;               # OUTPUT: «2451545␤»
    # alternatively use alias:
    say j2000;               # OUTPUT: «2451545␤»

### J1900

Julian date for 1899-12-31T12:00:00Z (astronomical epoch 1900.0).

    say J1900;               # OUTPUT: «2415020␤»
    # alternatively use alias:
    say j1900;               # OUTPUT: «2415020␤»

### sec-per-day

Seconds per 24-hour day.

    say sec-per-day;         # OUTPUT: «86400␤»

### sec-per-jcen

Seconds per Julian century.

    say sec-per-jcen;        # OUTPUT: «3155760000␤»

### days-per-jcen

Days per Julian century.

    say days-per-jcen;       # OUTPUT: «36525␤»

### solar2sidereal

Difference between Sidereal and Solar hour (the former is shorter).

    say solar2sidereal;      # OUTPUT: «1.002737909350795␤»

To do
=====

Add calculations (and tests) for Ephemeris Time and Universal Time. (See Ref. 1, section 3.4, p. 41.)

Notes
=====

1. A *proleptic calendar*, according to Wikipedia, "is a calendar that is applied to dates before its introduction."

References
==========

1. *Astronomy on the Personal Computer*, Oliver Montenbruck and Thomas Pfleger, Springer, 2000.

2. *Celestial Calculations: A Gentle Introduction to Computational Astronomy*, J. L. Lawrence, The MIT Press, 2019.

3. *Astro::Montenbruck*, Sergey Krushinsky, CPAN.

4. *Mapping Time: The Calendar and Its History*, E. G. Richards, Oxford University Press, 2000.

5. *Date Algorithms* (Version 5), Peter Baum, Aesir Research, 2020, [https://researchgate.net/publication/316558298](https://researchgate.net/publication/316558298).

See also
========

  * Raku module Astro::Utils

AUTHOR
======

Tom Browder (tbrowder@acm.org)

COPYRIGHT AND LICENSE
=====================

© 2021-2022, 2025 Tom Browder

