use strict;
use warnings;

package Class::XSAccessor::Test;

use Class::XSAccessor::Array
  constructor => 'new',
  accessors => { bar => 0, blubber => 2 },
  getters   => { get_foo => 1 },
  setters   => { set_foo => 1 };

package main;

use Test::More tests => 14;

ok (Class::XSAccessor::Test->can('new'));

my $obj = Class::XSAccessor::Test->new( bar => 'baz' );

ok ($obj->can('bar'));
is ($obj->set_foo('bar'), 'bar');
is ($obj->get_foo(), 'bar');
ok (!defined($obj->bar()));
is ($obj->bar('quux'), 'quux');
is ($obj->bar(), 'quux');

my $obj2 = $obj->new(bar => 'baz', 'blubber' => 'blabber');
ok ($obj2->can('bar'));
is ($obj2->set_foo('bar'), 'bar');
is ($obj2->get_foo(), 'bar');
ok (!defined($obj2->bar()));
is ($obj2->bar('quux'), 'quux');
is ($obj2->bar(), 'quux');
ok (!defined($obj2->blubber()));

