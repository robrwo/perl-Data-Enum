package Data::Enum;

use v5.10;

use strict;
use warnings;

use Package::Stash;
use Scalar::Util qw/ blessed refaddr /;

use overload ();

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

=back

This is done by creating a unique internal class name based on the
possible values.  Each value is actually a subclass of that class,
with the appropriate C<is_> method returning a constant.

=cut

my %Cache;
my $Counter;

sub new {
    my $this = shift;

    my @values = sort map { "$_" } @_;

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
                        Internals::SvREADONLY( my $value = $_ );
                        bless \$value, "${name}::${value}";
                    }
                } @values
            };
            my $self = $symbols->{$value} or die "invalid value: '$value'";
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
                my ( $self, $value ) = @_;
                return blessed($value)
                  ? refaddr($value) == refaddr($self)
                  : $value eq $$self;
            },
            q{ne} => sub {
                my ( $self, $value ) = @_;
                return blessed($value)
                  ? refaddr($value) != refaddr($self)
                  : $value ne $$self;
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
