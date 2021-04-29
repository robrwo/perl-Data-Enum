use Test::More;

use Scalar::Util qw/ refaddr /;

use_ok("Data::Enum");

ok my $colors = Data::Enum->new(qw/ red green blue /), 'new class';

is_deeply [ $colors->values ], [qw/ blue green red /], 'values';

ok !eval { $colors->new("pink") }, "bad enum caught";
like $@, qr/invalid value: 'pink'/, "expected error";

ok my $red = $colors->new("red"), "new item";

is_deeply [ $red->values ], [qw/ blue green red /], 'values';

isa_ok $red, $colors;

can_ok( $red, qw/ values is_red is_green is_blue / );

ok $red->is_red, 'is_red';
ok !$red->is_blue, '!is_blue';
ok !$red->is_green, '!is_green';

is "$red", "red", "stringify";

ok $red eq "red", "equality";
ok $red eq $red, "equality";
ok $colors->new("red") eq $red, "equality";

ok my $ro = $colors->new($red), "implicit clone";
is $ro, $red, "equality";

my $blue = $colors->new("blue");

ok !( $colors->new("blue") eq $red ), "equality";
ok $colors->new("blue") eq $blue, "equality";

ok !$blue->is_red, '!is_red';
ok $blue->is_blue, 'is_blue';
ok !$blue->is_green, '!is_green';

is refaddr($red), refaddr( $colors->new("red") ), 'refaddr equality';

ok my $alt = Data::Enum->new(qw/ green red blue /), 'new class';
is $alt, $colors, "cached classes";

for my $value (qw/ red green blue /) {
    is $colors->new($value), $alt->new($value), "same value";
}

my $sizes = Data::Enum->new(qw/ big small blue /);
isnt $sizes, $colors, "different classes";

isnt $sizes->new("blue"), $alt->new("blue"), "members of different classes are different";
isnt $sizes->new("small"), $alt->new("blue"), "members of different classes are different";

is $$red, "red", "deref";

ok !eval { $$red = "pink" }, 'changing value failed';
like $@, qr/Modification of a read-only value attempted/, "error when changing value";

is "$red", "red", "unchanged";

done_testing;
