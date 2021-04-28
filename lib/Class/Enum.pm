package Class::Enum;

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

    my @values = sort map {"$_"} @_;

    die "values must be alphanumeric" if !!grep { /\W/ } @values;

    my $key  = join chr(28), @values;

    if (my $name = $Cache{$key}) {
        return $name;
    }

    my $name = "Class::Enum::" . $Counter++;

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

        $elem->overload::OVERLOAD(
            q{""} => sub { $value },
            q{eq} => sub {
                my ($self, $value) = @_;
                return blessed($value)
                    ? refaddr($value) == refaddr($self)
                    : $value eq $$self;
            },
        );
    }

    return $Cache{$key} = $name;
}

=head1 SEE ALSO

L<Object::Enum>

=cut

1;
