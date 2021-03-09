unit class DateTime::Julian:ver<0.0.1>:auth<cpan:TBROWDER> is DateTime;

has DateTime $.dt;
has          $.juliandate;

submethod TWEAK {
    # instantiate the UTC DateTime object from the Julian day number
    # See J. L. Lawrence, p. 40
    my $frac = self.juliandate.abs = self.juliandate.Int.abs;

}

method frac($x) {
    self.frac: $x
}

sub frac($x) is export(:frac) {
    $x.abs - $x.Int.abs;
}


