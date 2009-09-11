#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper; $Data::Dumper::Terse = $Data::Dumper::Indent = 1;
use Test::More qw(no_plan);

our @WARNINGS = ();

use Class::XSAccessor
    constructor => 'new',
    __tests__   => [ qw(foo bar) ];

sub baz {
    my $self = shift;
    @_ ? $self->{baz} = shift : $self->{baz}
}

# standard: verify that the subs work as expected
sub test1 {
    my $self = shift;
    is($self->foo('foo1'), 'foo1');
    is($self->foo(), 'foo1');
    is($self->{foo}, 'foo1');
    is($self->bar('bar1'), 'bar1');
    is($self->bar(), 'bar1');
    is($self->{bar}, 'bar1');
}

# loop: verify that the second time through, the optimized entersub is called
sub test2 {
    my $self = shift;
    for (1 .. 2) {
        is($self->foo('foo2'), 'foo2');
        is($self->foo(), 'foo2');
        is($self->{foo}, 'foo2');
        is($self->bar('bar2'), 'bar2');
        is($self->bar(), 'bar2');
        is($self->{bar}, 'bar2');
    }
}

# dynamic
sub test3 {
    my $self = shift;
    for my $name (qw(foo bar)) {
        is($self->$name("${name}3"), "${name}3");
        is($self->$name(), "${name}3");
        is($self->{$name}, "${name}3");
    }
}

# dynamic with a twist: the second sub isn't Class::XSAccessor XSUB
# this should a) disable the optimization for the two entersub calls
# b) switch foo over to non-optimizing mode and c) (of course) still
# work as expected for foo and baz. the bar accessor should still be optimizing
sub test4 {
    my $self = shift;
    for my $name (qw(foo baz)) {
        is($self->$name("${name}4"), "${name}4");
        is($self->$name(), "${name}4");
        is($self->{$name}, "${name}4");
    }
    is($self->bar('bar4'), 'bar4');
    is($self->bar(), 'bar4');
    is($self->{bar}, 'bar4');
}

$SIG{__WARN__} = sub {
    my $warning = join '', @_;
    if ($warning =~ m{^cxah: (.+)\n$}) {
        push @WARNINGS, $1;
    }
};

my $self = main->new();

$self->test1();
$self->test2();
$self->test3();
$self->test4();
$self->test1();
$self->test2();
$self->test3();
$self->test4();

print Dumper(\@WARNINGS);
