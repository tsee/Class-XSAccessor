use strict;
use warnings;

use Test::More tests => 24;
BEGIN { use_ok('Class::XSAccessor') };

package Foo;
use Class::XSAccessor
  getters => {
    get_foo => 'foo',
    get_bar => 'bar',
  };
package main;

BEGIN {pass();}

package Foo;
use Class::XSAccessor
  replace => 1,
  getters => {
    get_foo => 'foo',
    get_bar => 'bar',
  };
package main;

BEGIN {pass();}

ok( Foo->can('get_foo') );
ok( Foo->can('get_bar') );

my $foo = bless  {foo => 'a', bar => 'b'} => 'Foo';
ok($foo->get_foo() eq 'a');
ok($foo->get_bar() eq 'b');


package Foo;
use Class::XSAccessor
  setters => {
    set_foo => 'foo',
    set_bar => 'bar',
  };

package main;
BEGIN{pass()}

ok( Foo->can('set_foo') );
ok( Foo->can('set_bar') );

$foo->set_foo('1');
pass();
$foo->set_bar('2');
pass();

ok($foo->get_foo() eq '1');
ok($foo->get_bar() eq '2');

# Make sure scalars are copied and not stored by reference (RT 38573)
my $x = 1;
$foo->set_foo($x);
$x++;
is( $foo->get_foo(), 1, 'scalar copied properly' );



# test that multiple methods can point to the same attr.
package Foo;
use Class::XSAccessor
  getters => {
    get_FOO => 'foo',
  },
  setters => {
    set_FOO => 'foo',
  };

package main;
BEGIN{pass()}

ok( Foo->can('get_foo') );
ok( Foo->can('get_bar') );

my $FOO = bless  {foo => 'a', bar => 'c'} => 'Foo';
ok( $FOO->can('get_FOO') );
ok( $FOO->can('set_FOO') );

ok($FOO->get_FOO() eq 'a');
ok($FOO->get_foo() eq 'a');
$FOO->set_FOO('b');
ok($FOO->get_FOO() eq 'b');
ok($FOO->get_foo() eq 'b');


