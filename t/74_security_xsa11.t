use strict;
use warnings;

use Test::More tests => 17;
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

  # Subclass inheritance: Derived calls inherited constructor
  {
    package TestCtorHashDerived;
    our @ISA = ('TestCtorHash');
  }
  my $derived = TestCtorHashDerived->new(d => 99);
  isa_ok($derived, "TestCtorHashDerived");
  is($derived->{d}, 99, "Derived class instance created via inheritance");

  my $derived_sub = $derived->new(d => 100);
  isa_ok($derived_sub, "TestCtorHashDerived");
  is($derived_sub->{d}, 100, "Derived class instance via instance invocant");

  # Invalid invocants: undef and unblessed reference
  my $undef;
  eval { TestCtorHash::new($undef); };
  like($@, qr/Can't call constructor on an undefined value/, "Hash constructor croaks on undef invocant");

  eval { TestCtorHash::new({}); };
  like($@, qr/Can't call constructor on an unblessed reference/, "Hash constructor croaks on unblessed hashref invocant");
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

  # Subclass inheritance for array-based class
  {
    package TestCtorArrayDerived;
    our @ISA = ('TestCtorArray');
  }
  my $derived = TestCtorArrayDerived->new();
  isa_ok($derived, "TestCtorArrayDerived");

  my $derived_sub = $derived->new();
  isa_ok($derived_sub, "TestCtorArrayDerived");

  # Invalid invocants: undef and unblessed reference
  my $undef;
  eval { TestCtorArray::new($undef); };
  like($@, qr/Can't call constructor on an undefined value/, "Array constructor croaks on undef invocant");

  eval { TestCtorArray::new([]); };
  like($@, qr/Can't call constructor on an unblessed reference/, "Array constructor croaks on unblessed arrayref invocant");

  eval { TestCtorArray::new({}); };
  like($@, qr/Can't call constructor on an unblessed reference/, "Array constructor croaks on unblessed hashref invocant");
}
