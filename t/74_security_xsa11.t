use strict;
use warnings;

use Test::More tests => 6;
use Class::XSAccessor ();
use Class::XSAccessor::Array ();

# 1. Constructor called on class name creates blessed instance
{
  Class::XSAccessor->import(
    class       => "TestCtorHash",
    constructor => "new",
  );
  my $obj = TestCtorHash->new(a => 1, b => 2);
  isa_ok($obj, "TestCtorHash");
  is($obj->{a}, 1, "Hash constructor sets attributes");

  # Calling constructor on blessed instance uses invocant's class
  my $sub = $obj->new(a => 10);
  isa_ok($sub, "TestCtorHash");
  is($sub->{a}, 10, "Hash constructor via instance works");
}

# 2. Array constructor called on class name and blessed instance
{
  Class::XSAccessor::Array->import(
    class       => "TestCtorArray",
    constructor => "new",
  );
  my $obj = TestCtorArray->new();
  isa_ok($obj, "TestCtorArray");

  my $sub = $obj->new();
  isa_ok($sub, "TestCtorArray");
}
