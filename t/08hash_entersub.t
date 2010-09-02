#!/usr/bin/env perl

use strict;
use warnings;

use Class::XSAccessor;

BEGIN {
    unless (Class::XSAccessor::__entersub_optimized__()) {
        print "1..0 # Skip entersub optimization not enabled", $/;
        exit;
    }
}

use Test::More tests => 103;
# use Data::Dumper; $Data::Dumper::Terse = $Data::Dumper::Indent = 1;

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

# dynamic with a twist: the second sub isn't a Class::XSAccessor XSUB.
# this should disable the optimization for the two entersub calls,
# and (of course) still work as expected for foo and baz.
# the bar accessor should still be optimizing
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

# call the methods as subs to see how this impacts the optimized entersub. XXX: passed as GVs
sub test5 {
    my $self = shift;
    is(foo($self, 'foo5'), 'foo5');
    is(foo($self), 'foo5');
    is($self->{foo}, 'foo5');
    is(bar($self, 'bar5'), 'bar5');
    is(bar($self), 'bar5');
    is($self->{bar}, 'bar5');
}

# call the methods as subs with & (this sets a flag in the entersub's op_private)
# XXX: these are passed in as GVs rather than CVs, which the optimization doesn't currently support
sub test6 {
    my $self = shift;
    is(&foo($self, 'foo6'), 'foo6');
    is(&foo($self), 'foo6');
    is($self->{foo}, 'foo6');
    is(&bar($self, 'bar6'), 'bar6');
    is(bar($self), 'bar6');
    is($self->{bar}, 'bar6');
}

# call the methods with $self->can('accessor_name') to see how this impacts the optimized entersub.
# XXX: methods found by can() are passed in as GVs, which the optimization doesn't currently
# support
sub test7 {
    my $self = shift;
    is($self->can('foo')->($self, 'foo7'), 'foo7');
    is($self->can('foo')->($self), 'foo7');
    is($self->{foo}, 'foo7');
    is($self->can('bar')->($self, 'bar7'), 'bar7');
    is($self->can('bar')->($self), 'bar7');
    is($self->{bar}, 'bar7');
}

$SIG{__WARN__} = sub {
    my $warning = join '', @_;

    if ($warning =~ m{^cxah: (.+)\n$}) {
        push @WARNINGS, $1;
    } else {
        warn @_; # from perldoc -f warn: "__WARN__ hooks are not called from inside one"
    }
};

my $self = main->new();

$self->test1();
$self->test2();
$self->test3();
$self->test4();
$self->test5();
$self->test6();
$self->test7();

$self->test1();
$self->test2();
$self->test3();
$self->test4();
$self->test5();
$self->test6();
$self->test7();

# The best way to verify this test is to a) look for lines above that should disable
# optimization and search for "disabling" below (e.g. ack disabling t/08hash_entersub.t),
# and/or b) look for "disabling" below and make sure it matches the behaviours above

my $WANT = [
    'accessor: inside test_init at t/08hash_entersub.t line 32.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 32.',
    'accessor: inside test_init at t/08hash_entersub.t line 33.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 33.',
    'accessor: inside test_init at t/08hash_entersub.t line 35.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 35.',
    'accessor: inside test_init at t/08hash_entersub.t line 36.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 36.',
    'accessor: inside test_init at t/08hash_entersub.t line 44.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 44.',
    'accessor: inside test_init at t/08hash_entersub.t line 45.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 45.',
    'accessor: inside test_init at t/08hash_entersub.t line 47.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 47.',
    'accessor: inside test_init at t/08hash_entersub.t line 48.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 48.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 44.',
    'accessor: inside test at t/08hash_entersub.t line 44.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 45.',
    'accessor: inside test at t/08hash_entersub.t line 45.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 47.',
    'accessor: inside test at t/08hash_entersub.t line 47.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 48.',
    'accessor: inside test at t/08hash_entersub.t line 48.',
    'accessor: inside test_init at t/08hash_entersub.t line 57.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 57.',
    'accessor: inside test_init at t/08hash_entersub.t line 58.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 58.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 57.',
    'accessor: inside test at t/08hash_entersub.t line 57.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 58.',
    'accessor: inside test at t/08hash_entersub.t line 58.',
    'accessor: inside test_init at t/08hash_entersub.t line 70.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 70.',
    'accessor: inside test_init at t/08hash_entersub.t line 71.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 71.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 70.',
    'entersub: disabling optimization: CV is not test at t/08hash_entersub.t line 70.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 71.',
    'entersub: disabling optimization: CV is not test at t/08hash_entersub.t line 71.',
    'accessor: inside test_init at t/08hash_entersub.t line 74.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 74.',
    'accessor: inside test_init at t/08hash_entersub.t line 75.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 75.',
    'accessor: inside test_init at t/08hash_entersub.t line 82.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 82.',
    'accessor: inside test_init at t/08hash_entersub.t line 83.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 83.',
    'accessor: inside test_init at t/08hash_entersub.t line 85.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 85.',
    'accessor: inside test_init at t/08hash_entersub.t line 86.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 86.',
    'accessor: inside test_init at t/08hash_entersub.t line 94.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 94.',
    'accessor: inside test_init at t/08hash_entersub.t line 95.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 95.',
    'accessor: inside test_init at t/08hash_entersub.t line 97.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 97.',
    'accessor: inside test_init at t/08hash_entersub.t line 98.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 98.',
    'accessor: inside test_init at t/08hash_entersub.t line 107.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 107.',
    'accessor: inside test_init at t/08hash_entersub.t line 108.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 108.',
    'accessor: inside test_init at t/08hash_entersub.t line 110.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 110.',
    'accessor: inside test_init at t/08hash_entersub.t line 111.',
    'accessor: op_spare: 0',
    'accessor: optimizing entersub at t/08hash_entersub.t line 111.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 32.',
    'accessor: inside test at t/08hash_entersub.t line 32.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 33.',
    'accessor: inside test at t/08hash_entersub.t line 33.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 35.',
    'accessor: inside test at t/08hash_entersub.t line 35.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 36.',
    'accessor: inside test at t/08hash_entersub.t line 36.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 44.',
    'accessor: inside test at t/08hash_entersub.t line 44.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 45.',
    'accessor: inside test at t/08hash_entersub.t line 45.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 47.',
    'accessor: inside test at t/08hash_entersub.t line 47.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 48.',
    'accessor: inside test at t/08hash_entersub.t line 48.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 44.',
    'accessor: inside test at t/08hash_entersub.t line 44.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 45.',
    'accessor: inside test at t/08hash_entersub.t line 45.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 47.',
    'accessor: inside test at t/08hash_entersub.t line 47.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 48.',
    'accessor: inside test at t/08hash_entersub.t line 48.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 57.',
    'accessor: inside test at t/08hash_entersub.t line 57.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 58.',
    'accessor: inside test at t/08hash_entersub.t line 58.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 57.',
    'accessor: inside test at t/08hash_entersub.t line 57.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 58.',
    'accessor: inside test at t/08hash_entersub.t line 58.',
    'accessor: inside test_init at t/08hash_entersub.t line 70.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 70.',
    'accessor: inside test_init at t/08hash_entersub.t line 71.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 71.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 74.',
    'accessor: inside test at t/08hash_entersub.t line 74.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 75.',
    'accessor: inside test at t/08hash_entersub.t line 75.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 82.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 82.',
    'accessor: inside test_init at t/08hash_entersub.t line 82.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 82.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 83.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 83.',
    'accessor: inside test_init at t/08hash_entersub.t line 83.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 83.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 85.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 85.',
    'accessor: inside test_init at t/08hash_entersub.t line 85.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 85.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 86.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 86.',
    'accessor: inside test_init at t/08hash_entersub.t line 86.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 86.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 94.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 94.',
    'accessor: inside test_init at t/08hash_entersub.t line 94.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 94.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 95.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 95.',
    'accessor: inside test_init at t/08hash_entersub.t line 95.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 95.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 97.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 97.',
    'accessor: inside test_init at t/08hash_entersub.t line 97.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 97.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 98.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 98.',
    'accessor: inside test_init at t/08hash_entersub.t line 98.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 98.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 107.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 107.',
    'accessor: inside test_init at t/08hash_entersub.t line 107.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 107.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 108.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 108.',
    'accessor: inside test_init at t/08hash_entersub.t line 108.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 108.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 110.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 110.',
    'accessor: inside test_init at t/08hash_entersub.t line 110.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 110.',
    'entersub: inside optimized entersub at t/08hash_entersub.t line 111.',
    'entersub: disabling optimization: sv is not a CV at t/08hash_entersub.t line 111.',
    'accessor: inside test_init at t/08hash_entersub.t line 111.',
    'accessor: op_spare: 1',
    'accessor: entersub optimization has been disabled at t/08hash_entersub.t line 111.'
];

is_deeply(\@WARNINGS, $WANT);

# print STDERR Dumper(\@WARNINGS), $/;
