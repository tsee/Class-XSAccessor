use strict;
use warnings;

use Test::More tests => 13;

BEGIN { use_ok('Class::XSAccessor') };

package Hash;

use Class::XSAccessor {
    accessors   => [ qw(foo bar) ],
    constructor => 'new'
};

package main;

my $hash = Hash->new();

isa_ok $hash, 'Hash';
can_ok $hash, 'foo', 'bar';

$hash->foo('FOO');
$hash->bar('BAR');

is $hash->foo, 'FOO';
is $hash->bar, 'BAR';

eval { Hash->foo };

like $@, qr{Class::XSAccessor: invalid instance method invocant: no hash ref supplied };

eval { Hash->bar };

like $@, qr{Class::XSAccessor: invalid instance method invocant: no hash ref supplied };

eval { Hash::foo() };

# package name introduced in 5.10.1
like $@, qr{Usage: (Hash::)?foo\(self, \.\.\.\) };

eval { Hash::bar() };

like $@, qr{Usage: (Hash::)?bar\(self, \.\.\.\) };

eval { Hash::foo( [] ) };

like $@, qr{Class::XSAccessor: invalid instance method invocant: no hash ref supplied };

eval { Hash::bar( '' ) };

like $@, qr{Class::XSAccessor: invalid instance method invocant: no hash ref supplied };

is Hash::foo($hash), 'FOO';
is Hash::bar($hash), 'BAR';
