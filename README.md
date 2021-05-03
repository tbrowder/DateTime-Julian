[![Actions Status](https://github.com/tbrowder/DateTime-Julian/workflows/test/badge.svg)](https://github.com/tbrowder/DateTime-Julian/actions)

DateTime::Julian
================

Provides a DateTime::Julian class (a subclass of Raku's class **DateTime**) that is instantiated by either a Julian Date (JD) or a Modified Julian Date (MJD).

SYNOPSIS
========

```raku
use DateTime::Julian;
my $jd  = nnnn.nnnn; # Julian Date for some event
my $mjd = nnnn.nnnn; # Modified Julian Date for some event
my $utc  = DateTime::Julian.new: :julian-date($jd);
my $utc2 = DateTime::Julian.new: :modified-julian-date($mjd);
```

DESCRIPTION
===========

Module **DateTime::Julian** defines a class (inherited from a Raku *DateTime* class) that is instantiated from a *Julian Date* or a *Modified Julian Date*.

Following are some pertinent definitions from Wikipedia topic [*Julian day*](https://en.m.wikipedia.org/wiki/Julian_day):

  * The **Julian day** is the continuous count of the days since the beginning of the Julian period, and is used primarily by astronomers....

  * The **Julian day number** (JDN) is the integer assigned to a whole solar day count starting from noon Universal time, with Julian day number 0 assigned to the day starting at noon on Monday, January 1, 4713 BC, proleptic [Note 1] Julian calendar (November 24, 4714 BC, in the proleptic Gregorian calendar), a date at which three multi-year cycles started (which are: indiction, Solar, and Lunar cycles) and which preceded any dates in recorded history. For example, the Julian day number for the day starting at 12:00 UT (noon) on January 1, 2000, was **2451545**.

  * The **Julian date** (JD) of any instant is the Julian day number plus the fraction of a day since the preceding noon in Universal Time. Julian dates are expressed as a Julian day number with a decimal fraction added. For example, the Julian date for 00:30:00.0 UT January 1, 2013, is **2456293.520833**.

The following methods and routines were developed from the descriptions of code in [References 1 and 2](#References). The author of Ref. 3 has been very helpful with this author's questions about astronomy and the implementation of astronomical routines.

The main purpose of this module is to simplify time and handling for this author who still finds Julian dates to be somewhat mysterious, but absolutely necessary for dealing with astronomy and predicting object positions, especially the Sun and Moon, for local observation and producing astronomical almanacs.

This module will play a major supporting role in this author's planned Raku module **Astro::Almanac**;

Class DateTime::Julian methods
==============================

method new
----------

    new(:$julian-date, :$modified-julian-date) {...}

If both arguments are entered, the *Julian Date* is used. If neither is entered, an exception is thrown.

Note that currently none of the ordinary DateTime *new* methods can be used for instantiation, but that could be done if someone can justify it.

method J2000
------------

method MJD0
-----------

method POSIX0
-------------

Class DateTime::Julian subroutines
==================================

sub jcal2gcal
-------------

sub gcal2jcal
-------------

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

AUTHOR
======

Tom Browder <tbrowder@cpan.org>

COPYRIGHT AND LICENSE
=====================

Copyright © 2021 Tom Browder

