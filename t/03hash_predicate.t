use strict;
use warnings;

package Class::XSAccessor::Test;

use Class::XSAccessor
  accessors  => { bar => 'bar' },
  getters    => { get_foo => 'foo' },
  setters    => { set_foo => 'foo' },
  predicates => { has_foo => 'foo', has_bar => 'bar' };

use Class::XSAccessor
  predicates => 'single';
use Class::XSAccessor
  predicates => [qw/mult iple/];

sub new {
  my $class = shift;
  bless { bar => 'baz' }, $class;
}

package main;

use Test::More tests => 18;

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

ok(!$obj->single);
ok(!$obj->mult);
ok(!$obj->iple);

$obj->{$_} = 1 for qw/single mult/;

ok($obj->single);
ok($obj->mult);
ok(!$obj->iple);

