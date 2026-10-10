use strict;
use warnings;

use Test::More tests => 5;
use Class::XSAccessor ();

# 1. Very long key rejection in Perl import
{
  my $huge_key = "a" x 10_000_001;
  eval {
    Class::XSAccessor->import(
      class   => "TestHugeKeyPerl",
      getters => { get_huge => $huge_key },
    );
  };
  like($@, qr/exceeds maximum supported length/, "Perl layer rejects key length > 10_000_000");
}

# 2. Key rejection at exactly the limit or below passes
{
  my $normal_key = "normal_key";
  eval {
    Class::XSAccessor->import(
      class   => "TestNormalKey",
      getters => { get_normal => $normal_key },
    );
  };
  is($@, '', "Normal key length succeeds");
  my $obj = bless { normal_key => 123 }, "TestNormalKey";
  is($obj->get_normal, 123, "Normal key accessor works");
}

# 3. Direct XS call newxs_getter with excessive key length
{
  my $huge_key = "k" x 10_000_001;
  eval {
    Class::XSAccessor::newxs_getter("TestDirectHuge::get_huge", $huge_key);
  };
  like($@, qr/exceeds maximum supported length/, "newxs_getter rejects key length > 10_000_000");
}

# 4. Direct XS call newxs_setter with excessive key length
{
  my $huge_key = "k" x 10_000_001;
  eval {
    Class::XSAccessor::newxs_setter("TestDirectHuge::set_huge", $huge_key, 0);
  };
  like($@, qr/exceeds maximum supported length/, "newxs_setter rejects key length > 10_000_000");
}
