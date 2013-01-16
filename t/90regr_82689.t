use strict;
use warnings;
use Test::More;

# Test for ticket 82689: The return value of the XS calls
# are the same (mutable) SV that was in the object itself.

sub get_pp { $_[0]->{X}; }
use Class::XSAccessor getters => { get_xs => 'X' };

SCOPE: {
  my $o   = bless { X=>1 }, 'main';
  my $ref = \($o->get_pp);
  $$ref++;
  is($o->get_pp, 1);
}

SCOPE: {
  my $o   = bless { X=>1 }, 'main';
  my $ref = \($o->get_xs);
  $$ref++;
  is($o->get_xs, 1);
}

done_testing;
