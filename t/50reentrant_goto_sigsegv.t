use strict;
use warnings;

use Class::XSAccessor;
use Test::More;

my $shim_calls;

sub install_accessor_with_shim {
  my ($class, $name, $field) = @_;

  $field = $name if not defined $field;

  Class::XSAccessor->import ({
    class => $class,
    getters => { $name => $field },
    replace => 1,
  });

  my $xs_cref = $class->can ($name);

  no strict 'refs';
  no warnings 'redefine';

  *{"${class}::${name}"} = sub {
    $shim_calls++;
    goto $xs_cref;
  };
}

for my $name (qw/bar baz/) {
  for my $pass (1..2) {

    $shim_calls = 0;

    install_accessor_with_shim ('Foo', $name);
    my $obj = bless ({ $name => 'a'}, 'Foo');

    is ($shim_calls, 0, "Reset number of calls ($name pass $pass)" );
    is ($obj->$name, 'a', "Accessor read works ($name pass $pass)" );
    is ($shim_calls, 1, "Shim called ($name pass $pass)" );

    eval { $obj->$name ('ack!') };
    ok ($@ =~ /Usage\: $name\(self\)/, "Exception from R/O accessor thrown ($name pass $pass)" );
    is ($shim_calls, 2, "Shim called anyway ($name pass $pass)" );

    eval { $obj->$name ('ick!') };
    ok ($@ =~ /Usage\: $name\(self\)/, "Exception from R/O accessor thrown once again ($name pass $pass)" );
    is ($shim_calls, 3, "Shim called again ($name pass $pass)" );
  }
}

done_testing;
