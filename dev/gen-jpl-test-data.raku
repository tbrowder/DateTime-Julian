#!/usr/bin/env raku

# NOTE: running this takes a bit less tha one minute in its present form

# based on email from Curt Tilmes:
use LibCurl::Easy;
use DOM::Tiny;

# JPL format (\%20 is the html space)
# "2000-01-20\%2013:01:09";  # JPL format
# '2000-01-20%2013:01:09';  # JPL format

# get times around midnight and noon
my @t = 
'11:59:59.99',  # JPL format
'12:00:00.00',  # JPL format
'13:00:00.01',  # JPL format
'23:59:59.99',  # JPL format
'24:00:00.00',  # JPL format
'00:00:00.01',  # JPL format
;

# assorted dates (AD and BC)
my @bc =
'4000-01-01',
'3000-01-01',
'2000-01-01',
'1000-01-01',
'0000-01-01',
;
my @ad = @bc.reverse;


my $of = 'jpl-test-data.dat';
my $fh = open $of, :w;
my $era = 'BC';
for @bc -> $d {
    for @t -> $t {
        my $date = "$d\%20$t";        
        my $webpage = LibCurl::Easy.new(URL => 'https://ssd.jpl.nasa.gov/tc.cgi#top',
                      postfields => "era={$era}&cd={$date}&z1=0&u_cal=Update").perform.content;
        my $dom = DOM::Tiny.parse($webpage);
        my $pre = $dom.find('pre');
        $fh.say: "$pre";
    }
}
$era = 'AD';
for @ad -> $d {
    for @t -> $t {
        my $date = "$d\%20$t";        
        my $webpage = LibCurl::Easy.new(URL => 'https://ssd.jpl.nasa.gov/tc.cgi#top',
                      postfields => "era={$era}&cd={$date}&z1=0&u_cal=Update").perform.content;
        my $dom = DOM::Tiny.parse($webpage);
        my $pre = $dom.find('pre');
        $fh.say: "$pre";
    }
}

$fh.close;
say "Normal end. See data file '$of'.";

=finish

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
