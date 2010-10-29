use strict;
use warnings;

package Class::XSAccessor::Test;

use Class::XSAccessor
  accessors  => { bar => 'bar' },
  getters    => { get_foo => 'foo', get_zero => 'zero' },
  setters    => { set_foo => 'foo' },
  predicates => { has_foo => 'foo', has_bar => 'bar', has_zero => 'zero' };

use Class::XSAccessor
  predicates => 'single';
use Class::XSAccessor
  predicates => [qw/mult iple/];

sub new {
  my $class = shift;
  bless { bar => 'baz', zero => 0 }, $class;
}

package main;

use Test::More tests => 20;

my $obj = Class::XSAccessor::Test->new();

ok($obj->can('has_foo'));
ok($obj->can('has_bar'));

ok(!$obj->has_foo());
ok($obj->has_bar());

is($obj->set_foo('bar'), 'bar');
is($obj->bar('quux'), 'quux');

ok($obj->has_foo());
ok($obj->has_bar());

is($obj->set_foo(undef), undef);
is($obj->bar(undef), undef);

ok(!$obj->has_foo());
ok(!$obj->has_bar());

is($obj->get_zero, 0);
ok($obj->has_zero);

ok(!$obj->single);
ok(!$obj->mult);
ok(!$obj->iple);

$obj->{$_} = 1 for qw/single mult/;

ok($obj->single);
ok($obj->mult);
ok(!$obj->iple);

