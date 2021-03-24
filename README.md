[![Actions Status](https://github.com/tbrowder/DateTime-Julian/workflows/test/badge.svg)](https://github.com/tbrowder/DateTime-Julian/actions)

NAME
====

DateTime::Julian - Provides routines to use astronomical Julian dates (sometimes called *Julian day numbers*)

SYNOPSIS
========

```raku
use DateTime::Julian;
my $jd = nnnn.nnnn; # Julian date for some event
my $utc = DateTime::Julian.new: :juliandate($jd);
say $utc.j2000; # Julian date for epoch J2000
say $utc.j1900; # Julian date for epoch J1900
say $utc.jcent;
say $utc.mjd;   # Modified Julian date
my $lon = -86.234; # local observer's longitude;
# Get the local sidereal time for the UTC at the current Julian date
my $lst = $utc.lst: :$lon;
```

DateTime::Julian
================

Module **DateTime::Julian** defines a class (inherited from a Raku *DateTime* class) that is usually instantiated from a *Julian date*, although it can also be instantiated by any of the methods described in the Raku documentation for a *DateTime* class;

Following are some pertinent definitions from Wikipedia topic [*Julian day*](https://en.m.wikipedia.org/wiki/Julian_day):

  * The **Julian day** is the continuous count of the days since the beginning of the Julian period, and is used primarily by astronomers....

  * The **Julian day number** (JDN) is the integer assigned to a whole solar day count starting from noon Universal time, with Julian day number 0 assigned to the day starting at noon on Monday, January 1, 4713 BC, proleptic [Note 1] Julian calendar (November 24, 4714 BC, in the proleptic Gregorian calendar), a date at which three multi-year cycles started (which are: indiction, Solar, and Lunar cycles) and which preceded any dates in recorded history. For example, the Julian day number for the day starting at 12:00 UT (noon) on January 1, 2000, was **2451545**.

  * The **Julian date** (JD) of any instant is the Julian day number plus the fraction of a day since the preceding noon in Universal Time. Julian dates are expressed as a Julian day number with a decimal fraction added. For example, the Julian date for 00:30:00.0 UT January 1, 2013, is **2456293.520833**.

The following methods and routines were developed from several sources including those shown in the [References](#References). The author of Ref. 3 has been very helpful with this author's questions about astronomy, and much of his code has been ported to Raku for this module. 

The main purpose of this module is to simplify time and handling for this author who still finds Julian dates to be somewhat mysterious, but absolutely necessary for dealing with astronomy and predicting object positions, especially the Sun and Moon, for local observation and producing astronomical almanacs.

Class DateTime::Julian methods
------------------------------

DateTime::Julian routines
-------------------------

Notes
=====

1. A *proleptic calendar*, according to Wikipedia, "is a calendar that is applied to dates before its introduction."

References
==========

1. *Astronomy on the Personal Computer*, Oliver Montenbruck and Thomas Pfleger, Springer, 2000.

2. *Celestial Calculations: A Gentle Introduction to Computational Astronomy*, J. L. Lawrence, The MIT Press, 2019.

3. *Astro::Montenbruck*, Sergey Krushinsky, CPAN.

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright © 2021 Tom Browder

Notes
=====

1. A *proleptic calendar*, according to Wikipedia, "is a calendar that is applied to dates before its introduction."

References
==========

1. *Astronomy on the Personal Computer*, Oliver Montenbruck and Thomas Pfleger, Springer, 2000.

2. *Celestial Calculations: A Gentle Introduction to Computational Astronomy*, J. L. Lawrence, The MIT Press, 2019.

3. *Astro::Montenbruck*, Sergey Krushinsky, CPAN.

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright © 2021 Tom Browder

This library is free software; you can redistribute it or modify it under the Artistic License 2.0.

