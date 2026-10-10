use strict;
use warnings;

use Test::More tests => 7;
use Class::XSAccessor::Array ();

{
  package TestArrayGetterPred;
  Class::XSAccessor::Array->import(
    class      => "TestArrayGetterPred",
    getters    => { get_val => 0 },
    predicates => { has_val => 0 },
  );

  sub new {
    my ($class, $val) = @_;
    bless [$val], $class;
  }
}

my $obj = TestArrayGetterPred->new("initial");

# 1. Getter returns the value
is($obj->get_val, "initial", "getter returns initial value");

# 2. Calling getter with extra arguments croaks (unlike accessor)
eval { $obj->get_val("attempted_overwrite"); };
like($@, qr/Usage:.*get_val\(self\)/, "getter rejects extra arguments with Usage error");
is($obj->get_val, "initial", "getter did not modify the slot");

# 3. Predicate returns true when slot is defined
ok($obj->has_val, "predicate is true for populated slot");

# 4. Calling predicate with extra argument croaks (unlike accessor)
eval { $obj->has_val("another_value"); };
like($@, qr/Usage:.*has_val\(self\)/, "predicate rejects extra arguments with Usage error");

# 5. Predicate on undef slot returns false
my $empty = TestArrayGetterPred->new(undef);
ok(!$empty->has_val, "predicate is false for undefined slot");
is($empty->get_val, undef, "getter returns undef for undefined slot");
