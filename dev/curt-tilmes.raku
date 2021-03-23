#!/usr/bin/env raku

=begin comment

# from Curt Tilmes:

It is a pretty basic HTTP form, so you could always just POST to it
and parse the results:

=end comment

use LibCurl::Easy;
use DOM::Tiny;

if 1 {
    my $era = 'BC';
    #my $era = 'AD';
    my $idate = "2000-Jan-20\%2013:01:09"; # JPL format
    my $webpage = LibCurl::Easy.new(URL => 'https://ssd.jpl.nasa.gov/tc.cgi#top',
                  postfields => "era={$era}&cd={$idate}&z1=0&u_cal=Update").perform.content;
    my $dom = DOM::Tiny.parse($webpage);
    my $pre = $dom.find('pre');
    say "$pre";
}
else {
    my $jdate = "2459272.55";
    my $webpage = LibCurl::Easy.new(URL => 'https://ssd.jpl.nasa.gov/tc.cgi#top',
                  postfields => "&jd={$jdate}&z1=0&u_jd=Update").perform.content;
    my $dom = DOM::Tiny.parse($webpage);
    my $pre = $dom.find('pre');
    say "$pre";
}
