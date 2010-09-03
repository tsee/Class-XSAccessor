use strict;
use warnings;

BEGIN {
  use Config;
  if (! $Config{'useithreads'}) {
    print("1..0 # SKIP Perl not compiled with 'useithreads'\n");
    exit(0);
  }
}

use constant NO_THREADS => 5;
# Not using Test::More simply because it's too much hassle to
# hack around issues with running in parallel.
print "1..6\n";
use threads;
use Class::XSAccessor;

my @chars = ('a'..'z', 'A'..'Z');

my @t;
foreach (1..NO_THREADS()) {
  push @t, threads->new(sub {
    my $no = shift;
    foreach (1..100) {
      my $foo = join '', map {$chars[rand(@chars)]} 1..5;
      Class::XSAccessor->import(
        replace => 1,
        class   => 'Foo',
        getters => {$foo => $foo}
      );
    }
    print "ok - thread $no\n";
  }, $_);
}

$_->join for @t;
print "ok - all reaped\n";

