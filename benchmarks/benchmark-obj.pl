package Foo;

use Moo;

use Data::Enum;

use List::Util qw( shuffle );

use Data::Enum;

my @values = shuffle qw( red green blue ultraviolet yellow black magenta bluegreen );
my $class  = Data::Enum->new(@values);
my $str    = $values[0];
my $member  = $class->new($str);

has e => (
    is      => 'lazy',
    builder => sub { return $member },
    handles => [ $class->predicates ],
);

has s => (
    is      => 'ro',
    default => $str,
);

package main;

use Benchmark qw( cmpthese );

my $o = Foo->new;

cmpthese(
    1_000_000,
    {
        'Data::Enum' => sub {
            $_ = $o->is_red;
            $_ = $o->is_blue;
            $_ = $o->is_bluegreen;
        },
        'eq' => sub {
            $_ = $o->s eq 'red';
            $_ = $o->s eq 'blue';
            $_ = $o->s eq 'bluegreen';
        },

    }
);
