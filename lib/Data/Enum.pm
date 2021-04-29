package Data::Enum;

# ABSTRACT: fast, immutable enumeration classes

use v5.10;

use strict;
use warnings;

use Package::Stash;
use List::Util 1.45 qw/ uniqstr /;
use Scalar::Util qw/ blessed refaddr /;

# RECOMMEND PREREQ: Package::Stash::XS

use overload ();

our $VERSION = 'v0.1.1';

=head1 SYNOPSIS

  use Data::Enum;

  my $color = Data::Enum->new( qw[ red yellow blue green ] );

  my $red = $color->new("red");

  $red->is_red;    # "1"
  $red->is_yellow; # "" (false)
  $red->is_blue;   # "" (false)
  $red->is_green;  # "" (false)

  say $red;        # outputs "red"

  $red eq $color->new("red"); # true

  $red eq "red"; # true

=head1 DESCRIPTION

This module will create enumerated constant classes with the following
properties:

=over

=item *

Any two classes with the same elements are equivalent.

The following two classes are the I<same>:

  my $one = Data::Enum->new( qw[ foo bar baz ] );
  my $two = Data::Enum->new( qw[ foo bar baz ] );

=item *

All class instances are singletons.

  my $one = Data::Enum->new( qw[ foo bar baz ] );

  my $a = $one->new("foo")
  my $b = $one->new("foo");

  refaddr($a) == $refaddr($b); # they are the same thing

=item *

Methods for checking values are fast.

  $a->is_foo; # constant time

  $a eq $b;   # compares refaddr

=item *

Values are immutable (read-only).

=back

This is done by creating a unique internal class name based on the
possible values.  Each value is actually a subclass of that class,
with the appropriate C<is_> method returning a constant.

=method new

  my $class = Data::Enum->new( @values );

This creates a new anonymous class. Values can be instantiated with a
constructor:

  my $instance = $class->new( $value );

Calling the constructor with an invalid value will throw an exception.

Each instance will have an C<is_> method for each value.

Each instance stringifies to its value.

=cut

my %Cache;
my $Counter;

sub new {
    my $this = shift;

    my @values = uniqstr( sort map { "$_" } @_ );

    die "values must be alphanumeric" if !!grep { /\W/ } @values;

    my $key = join chr(28), @values;

    if ( my $name = $Cache{$key} ) {
        return $name;
    }

    my $name = "Data::Enum::" . $Counter++;

    my $base = Package::Stash->new($name);

    $base->add_symbol(
        '&new',
        sub {
            my ( $class, $value ) = @_;
            state $symbols = {
                map {
                    $_ => do {
                        my $value = $_;
                        bless \$value, "${name}::${value}";
                    }
                } @values
            };
            my $self = $symbols->{"$value"} or die "invalid value: '$value'";
            return $self;
        }
    );

    for my $value (@values) {
        my $method = '&is_' . $value;
        $base->add_symbol( $method, sub { '' } );
        my $elem    = "${name}::${value}";
        my $subtype = Package::Stash->new($elem);
        $subtype->add_symbol( '@ISA',  [$name] );
        $subtype->add_symbol( $method, sub { 1 } );

        $elem->overload::OVERLOAD(
            q{""} => sub { $value },
            q{eq} => sub {
                my ( $self, $arg ) = @_;
                return blessed($arg)
                  ? refaddr($arg) == refaddr($self)
                  : $arg eq $value;
            },
            q{ne} => sub {
                my ( $self, $arg ) = @_;
                return blessed($arg)
                  ? refaddr($arg) != refaddr($self)
                  : $arg ne $value;
            },
        );
    }

    return $Cache{$key} = $name;
}

=head1 SEE ALSO

L<Class::Enum>

L<Object::Enum>

L<Type::Tiny::Enum>

=cut

1;
