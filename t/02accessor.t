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

use Test::More tests => 6;

my $obj = Class::XSAccessor::Test->new();

ok ($obj->can('bar'));
is ($obj->set_foo('bar'), 'bar');
is ($obj->get_foo(), 'bar');
is ($obj->bar(), 'baz');
is ($obj->bar('quux'), 'quux');
is ($obj->bar(), 'quux');
