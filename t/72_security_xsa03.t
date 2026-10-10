use strict;
use warnings;

use Test::More tests => 10;
use Class::XSAccessor ();
use Class::XSAccessor::Array ();

# 1. Old package separator ' normalization in Class::XSAccessor
{
  eval {
    Class::XSAccessor->import(
      class   => "TestOldSep",
      getters => { "TestOldSep'get_a" => "a" },
    );
  };
  is($@, '', "Can define accessor using old package separator '");
  my $obj = bless { a => 42 }, "TestOldSep";
  is($obj->get_a, 42, "Old package separator method works");
}

# 2. Old package separator ' normalization in Class::XSAccessor::Array
{
  eval {
    Class::XSAccessor::Array->import(
      class   => "TestOldSepArray",
      getters => { "TestOldSepArray'get_a" => 0 },
    );
  };
  is($@, '', "Can define array accessor using old package separator '");
  my $obj = bless [99], "TestOldSepArray";
  is($obj->get_a, 99, "Old package separator array method works");
}

# 3. Reject embedded NUL byte in subname via Class::XSAccessor
{
  eval {
    Class::XSAccessor->import(
      class   => "TestNul",
      getters => { "bad\0name" => "a" },
    );
  };
  like($@, qr/embedded NUL byte/, "Class::XSAccessor rejects embedded NUL in subname");
}

# 4. Reject embedded NUL byte in subname via Class::XSAccessor::Array
{
  eval {
    Class::XSAccessor::Array->import(
      class   => "TestNulArray",
      getters => { "bad\0name" => 0 },
    );
  };
  like($@, qr/embedded NUL byte/, "Class::XSAccessor::Array rejects embedded NUL in subname");
}

# 5. Direct XS call newxs_getter with embedded NUL byte
{
  eval {
    Class::XSAccessor::newxs_getter("TestDirectNul::get\0foo", "foo");
  };
  like($@, qr/embedded NUL byte/, "newxs_getter rejects embedded NUL");
}

# 6. Direct XS call newxs_setter with embedded NUL byte
{
  eval {
    Class::XSAccessor::newxs_setter("TestDirectNul::set\0foo", "foo", 0);
  };
  like($@, qr/embedded NUL byte/, "newxs_setter rejects embedded NUL");
}

# 7. Direct XS call Array::newxs_getter with embedded NUL byte
{
  eval {
    Class::XSAccessor::Array::newxs_getter("TestDirectNulArray::get\0foo", 0);
  };
  like($@, qr/embedded NUL byte/, "Array::newxs_getter rejects embedded NUL");
}

# 8. Direct XS call newxs_constructor with embedded NUL byte
{
  eval {
    Class::XSAccessor::newxs_constructor("TestDirectNul::new\0foo");
  };
  like($@, qr/embedded NUL byte/, "newxs_constructor rejects embedded NUL");
}
