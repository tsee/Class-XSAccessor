use strict;
use warnings;
use Test::More tests => 15;

use Class::XSAccessor::Array ();

# 1-6: Invalid array index via Class::XSAccessor::Array::import
for my $bad (-1, -100, 10_000_001, "abc", "1.5", undef) {
  my $disp = defined $bad ? $bad : 'undef';
  eval {
    Class::XSAccessor::Array->import({
      class => "TestPkgBad_$disp",
      getters => { get_val => $bad },
    });
  };
  like($@, qr/array index/i, "import rejects invalid array index ($disp)");
}

# 7-10: Invalid array index via direct XS calls
eval { Class::XSAccessor::Array::newxs_getter("TestPkgXS::get_neg", -1) };
like($@, qr/array index/i, "newxs_getter rejects negative array index -1");

eval { Class::XSAccessor::Array::newxs_getter("TestPkgXS::get_huge", 10_000_001) };
like($@, qr/array index/i, "newxs_getter rejects huge array index");

eval { Class::XSAccessor::Array::newxs_setter("TestPkgXS::set_neg", -1, 0) };
like($@, qr/array index/i, "newxs_setter rejects negative array index -1");

eval { Class::XSAccessor::Array::newxs_setter("TestPkgXS::set_huge", 10_000_001, 0) };
like($@, qr/array index/i, "newxs_setter rejects huge array index");

eval { Class::XSAccessor::Array::newxs_getter("TestPkgXS::get_64bit", 4294967296) };
like($@, qr/Invalid array index 4294967296: must be between 0 and 10000000/, "64-bit index formatted without truncation");

# 11-14: Valid array indices work correctly
eval {
  Class::XSAccessor::Array->import({
    class => "TestPkgGood",
    getters => { get_zero => 0, get_one => 1, get_max => 10_000_000 },
    setters => { set_zero => 0 },
  });
};
is($@, '', "import accepts valid array indices 0, 1, 10000000");

my $obj = bless [ "val0", "val1" ] => "TestPkgGood";
is($obj->get_zero, "val0", "get_zero returns slot 0");
is($obj->get_one, "val1", "get_one returns slot 1");
$obj->set_zero("new0");
is($obj->get_zero, "new0", "set_zero updates slot 0");
