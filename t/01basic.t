use strict;
use warnings;

use Test::More tests => 14;
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
  setters=> {
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

