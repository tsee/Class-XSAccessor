use strict;
use warnings;

package Class::XSAccessor::Test;

use Class::XSAccessor
  accessors => { bar => 'bar' },
  getters   => { get_foo => 'foo' },
  setters   => { set_foo => 'foo' };

sub new {
  my $class = shift;
  bless { bar => 'baz' }, $class;
}

package main;

use Test::More tests => 12;

my $obj = Class::XSAccessor::Test->new();

ok ($obj->can('bar'));
is ($obj->set_foo('bar'), 'bar');
is ($obj->get_foo(), 'bar');
is ($obj->bar(), 'baz');
is ($obj->bar('quux'), 'quux');
is ($obj->bar(), 'quux');

package Class::XSAccessor::Test2;
sub new {
  my $class = shift;
  bless { bar => 'baz' }, $class;
}

package main;
use Class::XSAccessor
  class     => 'Class::XSAccessor::Test2',
  accessors => { bar => 'bar' },
  getters   => { get_foo => 'foo' },
  setters   => { set_foo => 'foo' };

my $obj2 = Class::XSAccessor::Test2->new();
ok ($obj2->can('bar'));
is ($obj2->set_foo('bar'), 'bar');
is ($obj2->get_foo(), 'bar');
is ($obj2->bar(), 'baz');
is ($obj2->bar('quux'), 'quux');
is ($obj2->bar(), 'quux');

