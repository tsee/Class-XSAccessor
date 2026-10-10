use strict;
use warnings;

use Test::More tests => 6;
use Class::XSAccessor ();

# 1. Test that two keys with identical prefix before embedded NUL byte
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

# 2. Test hash table growth with keys containing embedded NUL bytes (>16 entries forces grow)
{
  my %getters;
  my %setters;
  for my $i (1 .. 30) {
    my $key = "prefix\0part$i";
    $getters{"get_attr_$i"} = $key;
    $setters{"set_attr_$i"} = $key;
  }

  Class::XSAccessor->import(
    class   => "TestNulGrowth",
    getters => \%getters,
    setters => \%setters,
  );

  my $obj = bless {}, "TestNulGrowth";
  for my $i (1 .. 30) {
    my $setter = "set_attr_$i";
    $obj->$setter("val_$i");
  }

  my $all_match = 1;
  for my $i (1 .. 30) {
    my $getter = "get_attr_$i";
    my $val = $obj->$getter();
    if ($val ne "val_$i") {
      $all_match = 0;
    }
  }
  ok($all_match, "All 30 keys with embedded NUL preserved across hash table grow/rehash");

  # Verify specific sample keys
  is($obj->get_attr_1, "val_1", "get_attr_1 correct after growth");
  is($obj->get_attr_15, "val_15", "get_attr_15 correct after growth");
  is($obj->get_attr_30, "val_30", "get_attr_30 correct after growth");
}
