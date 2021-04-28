package Data::Enum;

use v5.10;

use strict;
use warnings;

use Package::Stash;
use Scalar::Util qw/ blessed refaddr /;

use overload ();

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
