use strict;
use warnings;

package Class::XSAccessor::Test;

use Class::XSAccessor
  constructor => 'new',
  accessors => { bar => 'bar', blubber => 'blubber' },
  getters   => { get_foo => 'foo' },
  setters   => { set_foo => 'foo' };

package main;

use Test::More tests => 8;

ok (Class::XSAccessor::Test->can('new'));

my $obj = Class::XSAccessor::Test->new(bar => 'baz', 'blubber' => 'blabber');

ok ($obj->can('bar'));
is ($obj->set_foo('bar'), 'bar');
is ($obj->get_foo(), 'bar');
is ($obj->bar(), 'baz');
is ($obj->bar('quux'), 'quux');
is ($obj->bar(), 'quux');
is ($obj->blubber(), 'blabber');

