use strict;
use warnings;

use Test::More;
BEGIN { use_ok('Class::XSAccessor') };

package Foo;
use Class::XSAccessor
  cached_getters => {
    get_foo => 'foo',
    get_bar => 'bar',
  };

Class::XSAccessor->import(
  cached_accessors => {
    c => 'c',
  }
);

package main;

BEGIN {pass();}

package Foo;

my ($called, $expected_hashkey, $test_name, $retval);
sub set_testvars {($expected_hashkey, $retval, $test_name) = @_; $called = 0}
sub _get {
  my $self = shift;
  my $hashkey = shift;
  Test::More::is($hashkey, $expected_hashkey, "$test_name in _get");
  $called = 1;
  return $retval;
}

use Class::XSAccessor
  replace => 1,
  cached_getters => {
    get_foo => 'foo',
    get_bar => 'bar',
  };
package main;

BEGIN {pass();}

ok( Foo->can('get_foo') );
ok( Foo->can('get_bar') );
ok( Foo->can('c') );


my $foo = bless  {foo => undef, bar => 'b', c => 'd'} => 'Foo';
ok(not defined $foo->get_foo());
ok($foo->get_bar() eq 'b');

Foo::set_testvars('foo', '1234', "undef does hit cache");
ok(not defined $foo->get_foo());
ok(!$called, "initial call indeed hit cache");

can_ok($foo, 'c');
Foo::set_testvars('c', 42, "initial call hitting cache");
is($foo->c(), 'd');
ok(!$called, "initial call indeed hit cache");

delete $foo->{c};

Foo::set_testvars('c', 52, "call after deleting slot hits slow method");
is($foo->c(), '52');
ok($called, "_get was called");

$foo->c('bar');
Foo::set_testvars('c', 'baz', "accessor works as mutator");
is($foo->c(), 'bar');
ok(!$called, "_get was not called");

done_testing();
