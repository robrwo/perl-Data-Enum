use Test::More;

use Scalar::Util qw/ refaddr /;

use_ok("Class::Enum");

ok my $colors = Class::Enum->new(qw/ red green blue /), 'new class';

ok !eval { $colors->new("pink") }, "bad enum caught";
like $@, qr/invalid value: 'pink'/, "expected error";

ok my $red = $colors->new("red"), "new item";

isa_ok $red, $colors;

can_ok( $red, qw/ is_red is_green is_blue / );

ok $red->is_red, 'is_red';

is "$red", "red", "stringify";

ok $red eq "red", "equality";
ok $red eq $red, "equality";
ok $colors->new("red") eq $red, "equality";
ok !( $colors->new("blue") eq $red ), "equality";

is refaddr($red), refaddr( $colors->new("red") ), 'refaddr equality';

ok my $alt = Class::Enum->new(qw/ green red blue /), 'new class';
is $alt, $colors, "cached classes";

for my $value (qw/ red green blue /) {
    is $colors->new($value), $alt->new($value), "same value";
}

my $sizes = Class::Enum->new(qw/ big small /);
isnt $sizes, $colors, "different classes";

isnt $sizes->new("small"), $alt->new("blue");

is $$red, "red", "deref";

$$red = "pink";

is "$red", "red", "unchanged";

done_testing;
