package Class::Enum;

use v5.10;

use strict;
use warnings;

use Package::Stash;
use Scalar::Util qw/ blessed /;

use overload ();

my %Cache;
my $Counter;

sub new {
    my $this = shift;

    my @values = sort @_;

    my $key  = join chr(28), @values;
    my $name = $Cache{ $key } //= ( "Class::Enum::" . $Counter++ );

    my $base = Package::Stash->new($name);

    $base->add_symbol( '&new', sub {
        my ($class, $value) = @_;
        state $symbols = { map { $_ => bless \$_, "${name}::${_}" } @values };
        my $self = $symbols->{$value} or die "invalid value: '$value'";
        return $self;
    });

    for my $value (@values) {
        my $method = '&is_' . $value;
        $base->add_symbol( $method, sub { '' } );
        my $elem = "${name}::${value}";
        my $subtype = Package::Stash->new( $elem );
        $subtype->add_symbol( '@ISA', [$name] );
        $subtype->add_symbol( $method, sub { 1 } );

        $subtype->add_symbol( '&__string', sub { $value } );

        $subtype->add_symbol( '&__eq', sub {
            my ($self, $value) = @_;
            return blessed($value)
                ? ref($value) eq $elem
                : $value eq $$self;
        });

        $elem->overload::OVERLOAD(
            q{""} => '__string',
            q{eq} => '__eq',
        );
    }

    return $name;
}


1;
