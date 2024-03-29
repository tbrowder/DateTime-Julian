NAME
====

Astro::Montenbruck::Time - Time-related routines

VERSION
=======

Version 0.01

SYNOPSIS
========

    use Astro::Montenbruck::Time qw/:all/;

    # Convert Gregorian (new-style) date to old-style date
    my $j = cal2jd(1799, 6, 6); # Standard Julian date of A.Pushkin's birthday
    my $d = jd2cal($j, gregorian => 0) # (1799, 5, 25) = May 26, 1799.

    # Julian date in centuries since epoch 2000.0
    my $t = jd_cent($j); # -2.0056810403833
    ...

DESCRIPTION
===========

Library of date/time manipulation routines for practical astronomy. Most of them are based on so called *Julian date (JD)*, which is the number of days elapsed since mean UT noon of **January 1st 4713 BC**. This system of time measurement is widely adopted by the astronomers.

JD and MJD
----------

Many routines use Modified Julian date, which starts at **2000 January 0** (2000 January 1.0) as the starting point.

Civil year vs astronomical year
-------------------------------

There is disagreement between astronomers and historians about how to count the years preceding the year 1. Astronomers generally use zero-based system. The year before the year +1, is the year zero, and the year preceding the latter is the year -1. The year which the historians call 585 B.C. is actually the year -584.

In this module all subroutines accepting year assume that **there is year zero**. Thus, the sequence of years is: `BC -3, -2, -1, 0, 1, 2, 3, AD`.

Date and Time
-------------

Time is represented by fractional part of a day. For example, 7h30m UT is `(7 + 30 / 60) / 24 = 0.3125`.

### Gregorian calendar

*Civil calendar* in most cases means *proleptic Gregorian calendar*. it is assumed that Gregorian calendar started at Oct. 4, 1582, when it was first adopted in several European countries. Many other countries still used the older Julian calendar. In Soviet Russia, for instance, Gregorian system was accepted on Jan 26, 1918. See: [https://en.wikipedia.org/wiki/Gregorian_calendar#Adoption_of_the_Gregorian_Calendar](https://en.wikipedia.org/wiki/Gregorian_calendar#Adoption_of_the_Gregorian_Calendar)

EXPORTED CONSTANTS
==================

  * `$SEC_PER_DAY` seconds per day (86400)

  * `$SEC_PER_CEN` seconds per century (3155760000)

  * `$J2000` Standard Julian date for start of epoch 2000,0 (2451545)

  * `$J1900` Standard Julian date for start of epoch 1900,0 (2415020)

  * `$GREGORIAN_START` Start of Gregorian calendar, YYYYMMDD (15821004)

  * `$JD_UNIX_EPOCH` Standard Julian date for start of the Unix epoch

EXPORTED FUNCTIONS
==================

  * [/jd_cent($jd)](/jd_cent($jd))

  * [/after_gregorian($year, $month, $date)](/after_gregorian($year, $month, $date))

  * [/cal2jd($year, $month, $date)](/cal2jd($year, $month, $date))

  * [/jd2cal($jd)](/jd2cal($jd))

  * [/jd0($jd)](/jd0($jd))

  * [/unix2jd($seconds)](/unix2jd($seconds))

  * [/jd2unix($jd)](/jd2unix($jd))

  * [/jdnow()](/jdnow())

  * [/jd2mjd($jd)](/jd2mjd($jd))

  * [/mjd2jd($mjd)](/mjd2jd($mjd))

  * [/jd_cent($jd)](/jd_cent($jd))

  * [/t1900($jd)](/t1900($jd))

  * [/jd2dt($jd)](/jd2dt($jd))

  * [/jd2te($jd)](/jd2te($jd))

  * [/jd2gst($jd)](/jd2gst($jd))

  * [/jd2lst($jd, $lng)](/jd2lst($jd, $lng))

FUNCTIONS
=========

jd_cent($jd)
------------

Convert Standard Julian Date to centuries passed since epoch 2000.0

after_gregorian($year, $month, $date, gregorian_start => $YYYYMMDD )
--------------------------------------------------------------------

Does the given date fall to period after Gregorian calendar?

### Positional Arguments

  * **year** (astronomic, zero-based)

  * **month** (1-12)

  * **date** UTC date (1-31) with hours and minutes as decimal part

### Optional Named Arguments

  * **gregorian_start** — start of Gregorian calendar. Default value is **15821004** If the date is Julian ("old style"), use `undef` value. To provide non-standard start of Gregorian calendar, provide a number in format YYYYMMDDD, e.g. `19180126` for Jan 26, 1918.

### Returns

*true* or *false*.

cal2jd($year, $month, $date)
----------------------------

Convert civil date/time to Standard Julian date.

If `gregorian_start` argument is not provided, it is assumed that this is a date of *Proleptic Gregorian calendar*, which started at Oct. 4, 1582.

### Positional Arguments:

  * **year** (astronomic, zero-based)

  * **month** (1-12)

  * **date** UTC date (1-31) with hours and minutes as decimal part

### Optional Named Arguments

  * gregorian_start — start of Gregorian calendar. Default value is **15821004** If the date is Julian ("old style"), use `undef` value. To provide non-standard start of Gregorian calendar, provide a number in format YYYYMMDDD, e.g. `19180126` for Jan 26, 1918.

### Returns

Standard Julian date

jd2cal($jd)
-----------

Convert Standard Julian date to civil date/time

### Positional Arguments

Standard Julian Date

### Optional Named Arguments

  * gr1egorian — if i<true>, the result will be old-style (Julian) date

### Returns

A list corresponding to the input values of [/cal2jd($year, $month, $date)](/cal2jd($year, $month, $date)) function. The date is given in the proleptic Gregorian calendar system unless **gregorian** flag is set to *true*.

jd0($jd)
--------

Given Standard Julian Date, calculate Standard Julian date for midnight of the same date.

unix2jd($seconds)
-----------------

Given Unix (POSIX) time, in seconds, convert it to Standard Julian date.

jd2unix($jd)
------------

Given a Standard Julian Date, convert it to Unix time, in seconds since start of Unix epoch.

If JD falls before start of the epoch, result will be negative and thus, unusable for Unix-specific functions like **localtime()**.

jdnow()
-------

Standard Julian date for the current moment.

jd2mjd($jd)
-----------

Standard to Modified Julian date.

mjd2jd($mjd)
------------

Modified to Standard Julian date.

jd_cent($jd)
------------

Given a*Standard Julian date*, calculate time in centuries since epoch 2000.0.

t1900($jd)
----------

Given a *Standard Julian date*, calculate time in centuries since epoch 1900.0.

jd2gst($jd)
-----------

Given *Standard Julian date*, calculate *True Greenwich Sidereal time*.

jd2lst($jd, $lng)
-----------------

Given *Standard Julian date*, calculate true *Local Sidereal time*.

### Arguments

  * $jd — Standard Julian date

  * $lng — Geographic longitude, negative for Eastern longitude, 0 by default

AUTHOR
======

Sergey Krushinsky, `<krushi at cpan.org> `

LICENSE AND COPYRIGHT
=====================

© 2010-2019 Sergey Krushinsky.

This program is free software; you can redistribute it and/or modify it under the terms of either: the GNU General Public License as published by the Free Software Foundation; or the Artistic License.

See [http://dev.perl.org/licenses/](http://dev.perl.org/licenses/) for more information.

