unit module EG-Richards;

use Text::Utils :strip-comment;

#use lib <../lib>;
use Gen-Test :mon2num;

sub day-frac2hms(Real $x, :$debug --> List) is export {
    # Converts the fraction of a day into hours, minutes,
    # and seconds"
    my $hours   = $x * 24;
    my $hour    = $hours.Int;
    my $minutes = ($hours - $hour) * 60;
    my $minute  = $minutes.Int;
    my $second  = ($minutes - $minute) * 60;
    $hour, $minute, $second
}

sub day-frac(DateTime:D $dt, :$debug --> Real) is export {
    # Converts the hours, minutes, and seconds of an
    # instant into the decimal fraction of a 24-hour day.
    constant sec-per-day = 24 * 60 * 60;
    # get seconds in this day
    my $frac = $dt.hour * 60 * 60;
    $frac += $dt.minute * 60;
    $frac += $dt.second;
    # the day fraction
    $frac /= sec-per-day;
}

sub cal2jd(\Y, \M, $D, :$input where /:i g|j/, :$output where /:i g|j/, :$debug --> Real) is export {
    # Using Richards' algorithms
    my \D = $D.Int;
    my $day-frac = $D - D;

    # convert to the intermediate calendar form using equations ?

    # convert to the Gregorian calendar

    # convert to the Julian calendar
    my $jd = 0;
    # add the day fraction back
    $jd += $day-frac;
} # sub cal2jd

sub jd2cal($JD, :$gregorian = True, :$debug --> List) is export {
    # Using Richards' algorithms
    my \JD = $JD.Int;
    my $day-frac = $JD - JD;

    my $da = 0;
    # add the day fraction back
    $da += $day-frac;
} # sub jd2cal
