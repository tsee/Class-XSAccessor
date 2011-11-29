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

my ($called, $expected_hashkey, $test_name, $retval, $set_called);
sub set_testvars {
  ($expected_hashkey, $retval, $test_name) = @_;
  $set_called = $called = 0;
}
sub _get {
  Test::More::ok(@_ == 2, "num args in _get");
  my $self = shift;
  my $hashkey = shift;
  Test::More::is($hashkey, $expected_hashkey, "$test_name in _get");
  $called = 1;
  return $retval;
}
sub _set {
  Test::More::ok(@_ == 3, "num args in _set");
  my $self = shift;
  my $hashkey = shift;
  $self->{$hashkey} = shift;
  $set_called = 1;
  Test::More::is($hashkey, $expected_hashkey, "$test_name in _set");
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
ok(!$set_called);

Foo::set_testvars('c', 42, "initial call hitting cache");
is($foo->c(), 'd');
ok(!$called, "initial call indeed hit cache");
ok(!$set_called);

delete $foo->{c};

Foo::set_testvars('c', 52, "call after deleting slot hits slow method");
is($foo->c(), '52');
ok($called, "_get was called");
ok(!$set_called);

Foo::set_testvars('c', 'baz', "accessor works as mutator");
is($foo->c('bar'), 'bar');
ok($set_called);
ok(!$called);

Foo::set_testvars('c', 'baz', "accessor works as mutator");
is($foo->c(), 'bar');
ok(!$called, "_get was not called");
ok(!$set_called);

package Bar;
sub _get {
  my $self = shift;
  my $hashkey = shift;
  return();
}

use Class::XSAccessor
  cached_accessors => {
    foo => 'foo',
  };
package main;
my $bar = bless({} => 'Bar');
ok(not defined $bar->foo);
ok(exists $bar->{foo});
ok(not defined $bar->{foo});

done_testing();
