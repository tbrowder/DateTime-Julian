#!/usr/bin/env raku

my $ifil = 'jpl-test-data.dat';
my $ofil = '02-jpl-time-tests.t';

=begin comment
# one block of data from a JPL date/time <=> julian date tranformation:
<pre>

<b>Input Time Zone: UT</b>
-------------------------------------------------------
B.C. 4000-Jan-01 11:59:59.99 = B.C. 4000-Jan-01.4999999
B.C.  4000-01-01 11:59:59.99 = B.C.  4000-01-01.4999999
B.C.   4000--001 11:59:59.99 = B.C.   4000--001.4999999

Day-of-Week: Thursday

<b>Julian Date</b>
------------------
 260423.9999999 UT
</pre>
=end comment

if not @*ARGS {
    say qq:to/HERE/;
    Usage: {$*PROGRAM.basename} go [debug]

    Extracts data from file:

        $ifil

    and creates a draft test file at:

        $ofil
    HERE
    exit;
}

my $debug = 0;
for @*ARGS {
    when /:i ^d/ { $debug = 1 }
}

my $in-block = 0;
my $data-line = '';
my @data;
for $ifil.IO.lines {
    # parse data as triplets:
    #   ad|bc    date...
# B.C.  4000-01-01 11:59:59.99 = B.C.  4000-01-01.4999999
    #   day of week
# Day-of-Week: Thursday
    #   julian day
# 260423.9999999 UT
    when /'<pre>'/ { 
        $in-block = 1;
        @data.push: $data-line if $data-line;
        $data-line = '';
    }
    when /'</pre>'/ { 
        $in-block = 0;
    }
    when /^ \h* ('B.C.'|'A.D.') \h\h (\S+ \h+ \S+) \h+ '=' / {
        # B.C.  4000-01-01 11:59:59.99 = B.C.  4000-01-01.4999999
        my $era  = ~$0;
        my $date = ~$1;
        $data-line ~= ' | ' if $data-line;
        $data-line ~= $era;
        $data-line ~= ' | ';
        $data-line ~= $date;
    }
    when /^ \h* 'Day-of-Week:' \h+ (\S+) / {
        # Day-of-Week: Thursday
        my $dow  = ~$0;
        $data-line ~= ' | ' if $data-line;
        $data-line ~= $dow;
    }
    when /^ \h* (\d+ '.' \d+) \h+ UT/ {
        # 260423.9999999 UT
        my $jd  = +$0;
        $data-line ~= ' | ' if $data-line;
        $data-line ~= $jd;
    }
}

say "$_" for @data;


