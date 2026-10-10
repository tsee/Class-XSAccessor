use strict;
use warnings;

use Test::More tests => 2;
use Class::XSAccessor ();

# Test that two keys with identical prefix before embedded NUL byte
# and same MurmurHash bucket do not alias/collide in the internal hash registry (XSA-04)
{
  # In 16-bucket table:
  # "x\0foo1" and "x\0bar11" both hash to bucket 0 under MurmurHashNeutral2
  my $k1 = "x\0foo1";
  my $k2 = "x\0bar11";

  Class::XSAccessor->import(
    class   => "TestNulCollision",
    getters => { get_k1 => $k1, get_k2 => $k2 },
    setters => { set_k1 => $k1, set_k2 => $k2 },
  );

  my $obj = bless {}, "TestNulCollision";
  $obj->set_k1("VALUE_ONE");
  $obj->set_k2("VALUE_TWO");

  is($obj->get_k1, "VALUE_ONE", "Key 1 correctly retrieved without being clobbered by Key 2");
  is($obj->get_k2, "VALUE_TWO", "Key 2 correctly retrieved");
}
