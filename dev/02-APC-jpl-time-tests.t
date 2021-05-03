use Test;
use DateTime::Julian :formatter;
use DateTime::Julian::APC :ALL;

plan 120;

my %jpl =
    # using test data from the JPL website:
    #     https://ssd.jpl.nasa.gov/tc.cgi

    '+0001-01-01T11:59:59.99Z' => [1721423.9999999, 'Saturday', 6 ],
    '+0001-01-01T12:00:00.00Z' => [1721424, 'Saturday', 6 ],
    '+0001-01-01T13:00:00.01Z' => [1721424.0416668, 'Saturday', 6 ],
    '+0001-01-01T23:59:59.99Z' => [1721424.4999999, 'Saturday', 6 ],
    '+0001-01-02T00:00:00.00Z' => [1721424.5, 'Sunday', 7 ],
    '+0001-01-01T00:00:00.01Z' => [1721423.5000001, 'Saturday', 6 ],
    '+1000-01-01T11:59:59.99Z' => [2086307.9999999, 'Monday', 1 ],
    '+1000-01-01T12:00:00.00Z' => [2086308, 'Monday', 1 ],
    '+1000-01-01T13:00:00.01Z' => [2086308.0416668, 'Monday', 1 ],
    '+1000-01-01T23:59:59.99Z' => [2086308.4999999, 'Monday', 1 ],
    '+1000-01-02T00:00:00.00Z' => [2086308.5, 'Tuesday', 2 ],
    '+1000-01-01T00:00:00.01Z' => [2086307.5000001, 'Monday', 1 ],
    '+2000-01-01T11:59:59.99Z' => [2451544.9999999, 'Saturday', 6 ],
    '+2000-01-01T12:00:00.00Z' => [2451545, 'Saturday', 6 ],
    '+2000-01-01T13:00:00.01Z' => [2451545.0416668, 'Saturday', 6 ],
    '+2000-01-01T23:59:59.99Z' => [2451545.4999999, 'Saturday', 6 ],
    '+2000-01-02T00:00:00.00Z' => [2451545.5, 'Sunday', 7 ],
    '+2000-01-01T00:00:00.01Z' => [2451544.5000001, 'Saturday', 6 ],
    '+3000-01-01T11:59:59.99Z' => [2816787.9999999, 'Wednesday', 3 ],
    '+3000-01-01T12:00:00.00Z' => [2816788, 'Wednesday', 3 ],
    '+3000-01-01T13:00:00.01Z' => [2816788.0416668, 'Wednesday', 3 ],
    '+3000-01-01T23:59:59.99Z' => [2816788.4999999, 'Wednesday', 3 ],
    '+3000-01-02T00:00:00.00Z' => [2816788.5, 'Thursday', 4 ],
    '+3000-01-01T00:00:00.01Z' => [2816787.5000001, 'Wednesday', 3 ],
    '+4000-01-01T11:59:59.99Z' => [3182029.9999999, 'Saturday', 6 ],
    '+4000-01-01T12:00:00.00Z' => [3182030, 'Saturday', 6 ],
    '+4000-01-01T13:00:00.01Z' => [3182030.0416668, 'Saturday', 6 ],
    '+4000-01-01T23:59:59.99Z' => [3182030.4999999, 'Saturday', 6 ],
    '+4000-01-02T00:00:00.00Z' => [3182030.5, 'Sunday', 7 ],
    '+4000-01-01T00:00:00.01Z' => [3182029.5000001, 'Saturday', 6 ],
;

for %jpl.keys.sort -> $ut {
    # with key and value JPL test data
    my $jdin     = %jpl{$ut}[0];
    my $dowin    = %jpl{$ut}[1];
    my $downumin = %jpl{$ut}[2];
    my $dtin     = DateTime.new: $ut, :$formatter;
    #my $mjdin    = cal2mjd :year($dtin.year), :month($dtin.month), :day($dtin.day),
    #                       :hour($dtin.hour), :minute($dtin.minute), :second($dtin.second);
    my $mjdin    = jd2mjd $jdin;
    my $mjdinint = $dtin.daycount;

    # for now check that our 'daycount' agrees with JPL
    $mjdin .= floor;
    is $mjdin, $mjdinint;
    next;

    # the local tests:
    my $dtout = jd2dt :jd($jdin);
    is $dtout.day-of-week, $downumin, "dowin: $dowin $downumin out: {$dtout.day-of-week}";

    # compare jds
    my $mjdout   = cal2mjd :year($dtin.year), :month($dtin.month), :day($dtin.day),
                           :hour($dtin.hour), :minute($dtin.minute), :second($dtin.second);
    my $jdout = mjd2jd $mjdout;
    #$jdout .= round(0.7);

    #is $jdout, $jdin, "jd in: $jdin out: $jdout";
    is-approx $jdout, $jdin, "jd in: $jdin out: $jdout";

    =begin comment
    my $dtout = DateTime::Julian.new: :juliandate($jd), :$formatter;
    is $dtin, $dtout;
    =end comment

    =begin comment
    my $jd2dt = jd2dt :jd($jd);
    my $mjd = cal2mjd :year(self.year), :month(self.month), :day(self.day),
                  :hour(self.hour), :minute(self.minute), :second(self.second);
    =end comment

    =begin comment
    method new(:$juliandate) {
        my $dt = jd2dt :jd($jd);
        self.DateTime::new(
        :year($dt.year), :month($dt.month), :day($dt.day),
                  :hour($dt.hour), :minute($dt.minute), :second($dt.second));
    }
    submethod TWEAK() {
        my $mjd = cal2mjd :year(self.year), :month(self.month), :day(self.day),
                  :hour(self.hour), :minute(self.minute), :second(self.second);
        my $jd = mjd2jd $mjd;
        $!juliandate = $jd;
    }
    my $ut-dt = DateTime::Julian.new: $ut;
    my $jd-dt = DateTime::Julian.new: :juliandate($jd);
    is $ut-dt, $jd-ut;
    =end comment
}

