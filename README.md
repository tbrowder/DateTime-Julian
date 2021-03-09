[![Actions Status](https://github.com/tbrowder/DateTime-Julian/workflows/test/badge.svg)](https://github.com/tbrowder/DateTime-Julian/actions)

NAME
====

DateTime::Julian - Provides routines to use astronomical Julian dates (sometimes called *Julian day numbers*)

SYNOPSIS
========

```raku
use DateTime::Julian;
my $jd = nnnn.nnnn; # Julian date for 20
my $utc = DateTime::Julian.new: :juliandate($jd);
say $utc.j2000;
say $utc.jcent;
my $lon = -86.234; # local observer's latitude;
# Get the local sidereal time for the UTC at the current Julian date
my $lst = $utc.lst: :$lon;
```

DESCRIPTION
===========

DateTime::Julian contains a subclass of a DateTime object that is instantiated from a *Julian date*. 

Following are some pertinent definitions from Wikipedia topic *Julian day*:

  * The **Julian day** is the continous count of the days since the beginning of the Julian period, and is used primarily used by astronomers....

  * The **Julian day number** (JDN) is the integer assigned to a whole solar day count starting from noon Universal time, with Julian day number 0 assigned to the day starting at noon on Monday, January 1, 4713 BC, proleptic Julian calendar (November 24, 4714 BC, in the proleptic Gregorian calendar), a date at which three multi-year cycles started (which are: indiction, Solar, and Lunar cycles) and which preceded any dates in recorded history. For example, the Julian day number for the day starting at 12:00 UT (noon) on January 1, 2000, was **2451545**.

  * The **Julian date** (JD) of any instant is the Julian day number plus the fraction of a day since the preceding noon in Universal Time. Julian dates are expressed as a Julian day number with a decimal fraction added. For example, the Julian date for 00:30:00.0 UT January 1, 2013, is **2456293.520833**.

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright 2021 Tom Browder

This library is free software; you can redistribute it or modify it under the Artistic License 2.0.

