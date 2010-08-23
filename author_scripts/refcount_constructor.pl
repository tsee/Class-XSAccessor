#!/usr/bin/env perl

# confirm the refcounts/flags are correct for
# objects returned by the XS constructor

use Modern::Perl;
use Devel::Peek;

use blib;

use Class::XSAccessor {
    constructor => 'cxa',
};

sub normal {
    my $class = shift;
    bless { @_ }, ref($class) || $class;
}

{
    Dump(__PACKAGE__->cxa(foo => 'bar'));
    warn $/;
    Dump(__PACKAGE__->normal(foo => 'bar'));
}
