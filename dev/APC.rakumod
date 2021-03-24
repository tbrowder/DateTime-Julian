unit module APC;

#| This code is a Raku version of the algorithms described
#| in "Astronomy on the Personal Computer" by Oliver Montenbruck
#| and Thomas Pfleger.

# p. 8
sub Frac(Real \x --> Real) is export {
    x - x.floor
}

# p. 8
sub Modulo(Real \x, Real \y --> Real) is export {
    y * Frac(x/y)
}

# p. 9
sub Ddd(Int \D, Int \M, Real \S, :$debug --> Real) is export {
    my $sign = (D < 0 or M < 0 or S < 0) ?? -1 !! 1;
    if $debug {
        note qq:to/HERE/;
        DEBUG: routine Ddd
            input D: {D}
            input M: {M}
            input S: {S}
            D.abs  : {D.abs}
            M.abs/60.0 : {M.abs/60.0}                                                                           
            S.abs/60.0 : {S.abs/3600.0}                                                                            
        HERE
    }
    $sign * (D.abs + M.abs/60.0 + S.abs/3600.0)
}

# p. 9
enum AngleFormat is export ( 
    Dd      => 1,      # decimal repr
    DMM     => 2,     # deg and whole min of arc
    DMMm    => 3,    # deg and min of arc in decimal repr
    DMMSS   => 4,   # deg, min of arc and whole sec of arc
    DDMMSSs => 5, # deg, min, sec of arc in decimal repr
);

# pp. 9-10
class Angle is export {
    has Real $.alpha;
    has AngleFormat $.Format = Dd;

    method Set(AngleFormat $Format = Dd) {
        self.Format = $Format
    }
    method Str(AngleFormat $Format?) {
        my $fmt = $Format ?? $Format !! self.Format;
        given $fmt {
            when /Dd/ { 
                'Dd'
            }
            when /DMM/ { 
                'DMM'
            }
            when /DMMm/ { 
                'DMMm'
            }
            when /DMMSS/ { 
                'DMMSS'
            }
            when /DDMMSSs/ { 
                'DDMMSSs'
            }
        }
    }
}
