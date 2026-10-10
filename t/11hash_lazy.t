use strict;
use warnings;

package Class::XSAccessor::Test;
use Class::XSAccessor
  lazy_accessors      => { bar => 'bar' },
  lazy_getters        => { get_foo => 'foo' };
sub new {
  my $class = shift;
  bless { @_ }, $class;
}
sub _build_foo {
  my $self = shift;
  return ref($self) ? 111 : 333;
}
sub _build_bar {
  my $self = shift;
  return wantarray ? 444 : 222;
}
sub _build_get_foo {
  die "This should never be called.";
}

package Class::XSAccessor::TestChained;
our @ISA = 'Class::XSAccessor::Test';
use Class::XSAccessor
  chained             => 1,
  lazy_accessors      => { bar => 'bar' },
  lazy_getters        => { get_foo => 'foo' };

package main;
use Test::More tests => 18;

my $t1 = Class::XSAccessor::Test->new( foo => 42, bar => 43 );
is( $t1->get_foo, 42 );
is( $t1->bar, 43 );

my $t2 = Class::XSAccessor::Test->new;
ok( !exists $t2->{foo} );
is( $t2->get_foo, 111 );
is( $t2->{foo}, 111 );
ok( !exists $t2->{bar} );
is( $t2->bar, 222 );
is( $t2->{bar}, 222 );
ok !eval { $t2->get_foo(333); 1 };

my $t3 = Class::XSAccessor::Test->new( foo => undef, bar => undef );
is( $t3->get_foo, undef );
is( $t3->bar, undef );
ok( !defined $t3->{bar} );
delete $t3->{bar};
ok( !exists $t3->{bar} );
is( $t3->bar, 222 );
is( $t3->{bar}, 222 );

my $t4 = Class::XSAccessor::TestChained->new( foo => 42, bar => 43 );
is( $t4->get_foo, 42 );
is( $t4->bar, 43 );
is( $t4->bar(55), $t4 );
