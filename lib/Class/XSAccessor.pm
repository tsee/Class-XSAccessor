package Class::XSAccessor;
use 5.008;
use strict;
use warnings;
use Carp qw/croak/;
use Class::XSAccessor::Heavy;
use XSLoader;

our $VERSION = '1.13_01';

XSLoader::load('Class::XSAccessor', $VERSION);

sub _make_hash {
  my $ref = shift;

  if (ref ($ref)) {
    if (ref($ref) eq 'ARRAY') {
      $ref = { map { $_ => $_ } @$ref }
    } 
  } else {
    $ref = { $ref, $ref };
  }

  return $ref;
}

sub import {
  my $own_class = shift;
  my ($caller_pkg) = caller();

  # Support both { getters => ... } and plain getters => ...
  my %opts = ref($_[0]) eq 'HASH' ? %{$_[0]} : @_;

  $caller_pkg = $opts{class} if defined $opts{class};

  # TODO: Refactor. Move more duplicated code to ::Heavy
  my $read_subs        = _make_hash($opts{getters} || {});
  my $set_subs         = _make_hash($opts{setters} || {});
  my $acc_subs         = _make_hash($opts{accessors} || {});
  my $lvacc_subs       = _make_hash($opts{lvalue_accessors} || {});
  my $pred_subs        = _make_hash($opts{predicates} || {});
  my $test_subs        = _make_hash($opts{__tests__} || {});
  my $cached_read_subs = _make_hash($opts{cached_getters} || {});
  my $cached_acc_subs  = _make_hash($opts{cached_accessors} || {});
  my $construct_subs   = $opts{constructors} || [defined($opts{constructor}) ? $opts{constructor} : ()];
  my $true_subs        = $opts{true} || [];
  my $false_subs       = $opts{false} || [];

  foreach my $subtype ( ["getter", $read_subs],
                        ["setter", $set_subs],
                        ["accessor", $acc_subs],
                        ["lvalue_accessor", $lvacc_subs],
                        ["test", $test_subs],
                        ["predicate", $pred_subs],
                        ["cached_getter", $cached_read_subs],
                        ["cached_accessor", $cached_acc_subs], )
  {
    my $subs = $subtype->[1];
    foreach my $subname (keys %$subs) {
      my $hashkey = $subs->{$subname};
      _generate_method($caller_pkg, $subname, $hashkey, \%opts, $subtype->[0]);
    }
  }

  foreach my $subtype ( ["constructor", $construct_subs],
                        ["true", $true_subs],
                        ["false", $false_subs] )
  {
    foreach my $subname (@{$subtype->[1]}) {
      _generate_method($caller_pkg, $subname, "", \%opts, $subtype->[0]);
    }
  }
}

sub _generate_method {
  my ($caller_pkg, $subname, $hashkey, $opts, $type) = @_;

  croak("Cannot use undef as a hash key for generating an XS $type accessor. (Sub: $subname)")
    if not defined $hashkey;

  $subname = "${caller_pkg}::$subname" if $subname !~ /::/;

  Class::XSAccessor::Heavy::check_sub_existence($subname) if not $opts->{replace};
  no warnings 'redefine'; # don't warn about an explicitly requested redefine

  if ($type eq 'getter') {
    newxs_getter($subname, $hashkey);
  }
  elsif ($type eq 'cached_getter') {
    newxs_cached_getter($subname, $hashkey);
  }
  elsif ($type eq 'lvalue_accessor') {
    newxs_lvalue_accessor($subname, $hashkey);
  }
  elsif ($type eq 'setter') {
    newxs_setter($subname, $hashkey, $opts->{chained}||0);
  }
  elsif ($type eq 'predicate') {
    newxs_predicate($subname, $hashkey);
  }
  elsif ($type eq 'constructor') {
    newxs_constructor($subname);
  }
  elsif ($type eq 'true') {
    newxs_boolean($subname, 1);
  }
  elsif ($type eq 'false') {
    newxs_boolean($subname, 0);
  }
  elsif ($type eq 'test') {
    newxs_test($subname, $hashkey);
  }
  elsif ($type eq 'cached_accessor') {
    newxs_cached_accessor($subname, $hashkey, 0); # no chained variant available
  }
  else {
    newxs_accessor($subname, $hashkey, $opts->{chained}||0);
  }
}

1;

__END__

=head1 NAME

Class::XSAccessor - Generate fast XS accessors without runtime compilation

=head1 SYNOPSIS

  # This synopsis just shows all accessor types available,
  # in reality, you'd typically only use one or few of them.
  package MyClass;
  use Class::XSAccessor
    replace     => 1,   # Replace existing methods (if any)
    constructor => 'new',
    getters     => {
      get_foo => 'foo', # 'foo' is the hash key to access
      get_bar => 'bar',
    },
    setters => {
      set_foo => 'foo',
      set_bar => 'bar',
    },
    accessors => {
      foo => 'foo',
      bar => 'bar',
    },
    predicates => {
      has_foo => 'foo',
      has_bar => 'bar',
    },
    lvalue_accessors => { # see below
      baz => 'baz', # ...
    },
    cached_getters => { # see below
      get_blargl => 'blargl', # ...
    },
    cached_accessors => { # see below
      blargl => 'blargl', # ...
    },
    true  => [ 'is_token', 'is_whitespace' ],
    false => [ 'significant' ];
  
  # The imported methods are implemented in fast XS.
  
  # normal class code here.

As of version 1.05, some alternative syntax forms are available:

  package MyClass;
  
  # Options can be passed as a HASH reference, if preferred,
  # which can also help Perl::Tidy to format the statement correctly.
  use Class::XSAccessor {
     # If the name => key values are always identical,
     # the following shorthand can be used.
     accessors => [ 'foo', 'bar' ],
  };

=head1 DESCRIPTION

Class::XSAccessor implements fast read, write and read/write accessors in XS.
Additionally, it can provide predicates such as C<has_foo()> for testing
whether the attribute C<foo> is defined in the object.
It only works with objects that are implemented as ordinary hashes.
L<Class::XSAccessor::Array> implements the same interface for objects
that use arrays for their internal representation.

Since version 0.10, the module can also generate simple constructors
(implemented in XS). Simply supply the
C<constructor =E<gt> 'constructor_name'> option or the
C<constructors =E<gt> ['new', 'create', 'spawn']> option.
These constructors do the equivalent of the following Perl code:

  sub new {
    my $class = shift;
    return bless { @_ }, ref($class)||$class;
  }

That means they can be called on objects and classes but will not
clone objects entirely. Parameters to C<new()> are added to the
object.

The XS accessor methods are between 3 and 5 times faster than typical
pure-Perl accessors in some simple benchmarking.
The lower factor applies to the potentially slightly obscure
C<sub set_foo_pp {$_[0]-E<gt>{foo} = $_[1]}>, so if you usually
write clear code, at least a factor of 3.5 speed-up is a good estimate.
If in doubt, do your own benchmarking!

The method names may be fully qualified. The example in the synopsis could
have been written as C<MyClass::get_foo> instead
of C<get_foo>. This way, methods can be installed in classes other
than the current class. See also: the C<class> option below.

By default, the setters return the new value that was set,
and the accessors (mutators) do the same. This behaviour can be changed
with the C<chained> option - see below. The predicates return a boolean.

Since version 1.01, C<Class::XSAccessor> can generate extremely simple methods which
just return true or false (and always do so). If that seems like a
really superfluous thing to you, then consider a large class hierarchy
with interfaces such as L<PPI>. These methods are provided by the C<true>
and C<false> options - see the synopsis.

=head1 OPTIONS

In addition to specifying the types and names of accessors, additional options
can be supplied which modify behaviour. The options are specified as key/value pairs
in the same manner as the accessor declaration. For example:

  use Class::XSAccessor
    getters => {
      get_foo => 'foo',
    },
    replace => 1;

The list of available options is:

=head2 replace

Set this to a true value to prevent C<Class::XSAccessor> from
complaining about replacing existing subroutines.

=head2 chained

Set this to a true value to change the return value of setters
and mutators (when called with an argument).
If C<chained> is enabled, the setters and accessors/mutators will
return the object. Mutators called without an argument still
return the value of the associated attribute.

As with the other options, C<chained> affects all methods generated
in the same C<use Class::XSAccessor ...> statement.

=head2 class

By default, the accessors are generated in the calling class. The
the C<class> option allows the target class to be specified.

=head1 CACHED ACCESSORS

It takes a couple of words to explain what I mean by I<cached getter>
and I<cached accessor>. But most of that can be done away with by
telling you what Perl code the I<cached getters> implement more efficiently:

  sub get_foo {
    my $self = shift;
    if (not exists($self->{foo})) {
      $self->{foo} = $self->_get("foo");
    }
    return $self->{foo};
  }

Similarly, I<cached accessors> implement the following:

  sub foo {
    my $self = shift;
    if (@_) {
      $self->_set("foo", $_[0]);
      return $_[0];
    }
    else {
      if (not exists($self->{foo})) {
        $self->{foo} = $self->_get("foo");
      }
      return $self->{foo};
    }
  }

This means that both the read-only accessor/getter C<get_foo> and the
read-write accessor C<foo> will return the value stored in the C<$self>
hash as the "foo" entry if it exists (and in the rw case, if called
without additional arguments). If that hash entry does not exist, both
will call the C<_get> method (to be implemented by you) with the hash key
name "foo" as argument and set the hash entry "foo" to whatever C<_get>
returns.

The rw-accessor will call the C<_set> method (again, to be implemented by
you) if you provide additional arguments.

This implements a form of lazy evaluation commonly found in ORMs.
The important feature here is that the most common case -- the corresponding
hash entry is to be fetched from the very hash -- will be very fast. Only
if it doesn't exist, more expensive calculations will be made (such as
fetching data from a database). Note that if either C<_get> or C<_set>
needs to be invoked, the overall performance will be similar
(slightly faster on my machine in a trivial benchmark) 
to the pure-Perl implementation since calling into Perl from C is very slow.

=head1 LVALUES

Support for lvalue accessors via the keyword C<lvalue_accessors>
was added in version 1.08. At this point, B<THEY ARE CONSIDERED HIGHLY
EXPERIMENTAL>. Furthermore, their performance hasn't been benchmarked
yet.

The following example demonstrates an lvalue accessor:

  package Address;
  use Class::XSAccessor
    constructor => 'new',
    lvalue_accessors => { zip_code => 'zip' };
  
  package main;
  my $address = Address->new(zip => 2);
  print $address->zip_code, "\n"; # prints 2
  $address->zip_code = 76135; # <--- This is it!
  print $address->zip_code, "\n"; # prints 76135

=head1 CAVEATS

Probably won't work for objects based on I<tied> hashes. But that's a strange thing to do anyway.

Scary code exploiting strange XS features.

If you think writing an accessor in XS should be a laughably simple exercise, then
please contemplate how you could instantiate a new XS accessor for a new hash key
that's only known at run-time. Note that compiling C code at run-time a la L<Inline::C|Inline::C>
is a no go.

Threading. With version 1.00, a memory leak has been B<fixed>. Previously, a small amount of
memory would leak if C<Class::XSAccessor>-based classes were loaded in a subthread without having
been loaded in the "main" thread. If the subthread then terminated, a hash key and an int per
associated method used to be lost. Note that this mattered only if classes were B<only> loaded
in a sort of throw-away thread.

In the new implementation, as of 1.00, the memory will still not be released, in the same situation,
but it will be recycled when the same class, or a similar class, is loaded again in B<any> thread.

=head1 SEE ALSO

=over

=item * L<Class::XSAccessor::Array>

=item * L<AutoXS>

=back

=head1 AUTHOR

Steffen Mueller E<lt>smueller@cpan.orgE<gt>

chocolateboy E<lt>chocolate@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008, 2009, 2010, 2011 by Steffen Mueller

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
