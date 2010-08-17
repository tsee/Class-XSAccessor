use strict;
use warnings;

use Test::More tests => 6;
BEGIN { use_ok('Class::XSAccessor') };

package Foo;
use Class::XSAccessor
  lvalue_accessors => {
    "bar" => "bar2"
  };

package main;

BEGIN {pass();}

ok( Foo->can('bar') );

my $foo = bless  {bar2 => 'b'} => 'Foo';
my $x = $foo->bar();
ok($x eq 'b');
$foo->bar = "buz";
ok($x eq 'b');
ok($foo->bar() eq 'buz');

