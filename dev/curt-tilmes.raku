#!/usr/bin/env raku

=begin comment

# from Curt Tilmes:

It is a pretty basic HTTP form, so you could always just POST to it
and parse the results:

=end comment

use LibCurl::Easy;
use DOM::Tiny;

my $idate = "2000-Jan-20\%2013:01:09"; # JPL format
my $webpage = LibCurl::Easy.new(URL => 'https://ssd.jpl.nasa.gov/tc.cgi#top',
              #postfields => 'era=AD&cd=2021-Mar-18%2015:57:09&z1=-5&u_z2=off&z2=-5&u_cal=Update&jd=2459292.164875').perform.content;
              #postfields => 'era=AD&cd=2020-Jun-16%2015:23:57&z1=0&u_cal=Update').perform.content;
              postfields => "era=AD&cd={$idate}&z1=0&u_cal=Update").perform.content;

my $dom = DOM::Tiny.parse($webpage);

#say ~$dom.find('pre');
my $pre = $dom.find('pre');
say "$pre";
