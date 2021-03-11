#!/usr/bin/env raku

class Parent {
    has $.name;
}

my $p = Parent.new: :name<Joe>;
say $p.name;

class Child is Parent {
    has Real $.j;
    multi method new(Real:D $j) {
        self.bless(:$j)
    }
}
my $c = Child.new: :j(2), :name<Sam>;
say $c.name;
say $c.j;

