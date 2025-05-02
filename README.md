# NAME

Data::Enum - immutable enumeration classes

# VERSION

version v0.6.1

# SYNOPSIS

```perl
use Data::Enum;

my $color = Data::Enum->new( qw[ red yellow blue green ] );

my $red = $color->new("red");

$red->is_red;    # "1"
$red->is_yellow; # "0" (false)
$red->is_blue;   # "0" (false)
$red->is_green;  # "0" (false)

say $red;        # outputs "red"

$red eq $color->new("red"); # true

$red eq "red"; # true
```

# DESCRIPTION

This module will create enumerated constant classes with the following
properties:

- Any two classes with the same elements are equivalent.

    The following two classes are the _same_:

    ```perl
    my $one = Data::Enum->new( qw[ foo bar baz ] );
    my $two = Data::Enum->new( qw[ baz bar foo ] );
    ```

- All class instances are singletons.

    ```perl
    my $one = Data::Enum->new( qw[ foo bar baz ] );

    my $a = $one->new("foo")
    my $b = $one->new("foo");

    refaddr($a) == refaddr($b); # they are the same thing
    ```

- Methods for checking values are fast.

    ```
    $a->is_foo; # constant time

    $a eq $b;   # compares refaddr
    ```

- Values are immutable (read-only).

This is done by creating a unique internal class name based on the
possible values.  Each value is actually a subclass of that class,
with the appropriate predicate method returning a constant.

# METHODS

## new

```perl
my $class = Data::Enum->new( @values );
```

This creates a new anonymous class. Values can be instantiated with a
constructor:

```perl
my $instance = $class->new( $value );
```

Calling the constructor with an invalid value will throw an exception.

Each instance will have a predicate `is_` method for each value.

The values are case sensitive.

Each instance stringifies to its value.

Since v0.3.0 you can change the specify options in the class generator:

```perl
my $class = Data::Enum->new( \%options, @values );
```

The following options are supported:

- prefix

    Change prefix of the predicate methods to something other than `is_`. For example,

    ```perl
    my $class = Data::Enum->new( { prefix => "from_" }, "home", "work" );
    my $place = $class->new("work");

    $place->from_home;
    ```

    This was added in v0.3.0.

- name

    This assigns a name to the class, so instances can be constructed by name:

    ```perl
    my $class = Data::Enum->new( { name => "Colours" }, "red", "orange", "yellow", "green" );

    my $color = Colours->new("yellow");
    ```

    This was added in v0.5.0.

## values

```perl
my @values = $class->values;
```

Returns a list of valid values, stringified and sorted with duplicates
removed.

This was added in v0.2.0.

## predicates

```perl
my @predicates = $class->predicates;
```

Returns a list of predicate methods for each value.

A hash of predicates to values is roughly

```perl
use List::Util 1.56 'mesh';

my %handlers = mesh [ $class->values ], [ $class->predicates ];
```

This was added in v0.2.1.

## prefix

This returns the prefix.

This was added in v0.3.0.

## MATCH

This method adds support for [match::simple](https://metacpan.org/pod/match%3A%3Asimple).

## as\_string

This stringifies the the object.

This was added in v0.4.0.

# CAVEATS

The overheard of creating a new class instance and resolving methods may actually take more time than comparing simple
strings.  When using this in production code, you may want to benchmark performance.

# SUPPORT FOR OLDER PERL VERSIONS

This module requires Perl v5.20 or later.

Future releases may only support Perl versions released in the last ten (10) years.

# SEE ALSO

[Class::Enum](https://metacpan.org/pod/Class%3A%3AEnum)

[Object::Enum](https://metacpan.org/pod/Object%3A%3AEnum)

[MooX::Enumeration](https://metacpan.org/pod/MooX%3A%3AEnumeration)

[MooseX::Enumeration](https://metacpan.org/pod/MooseX%3A%3AEnumeration)

[Type::Tiny::Enum](https://metacpan.org/pod/Type%3A%3ATiny%3A%3AEnum)

# SOURCE

The development version is on github at [https://github.com/robrwo/perl-Data-Enum](https://github.com/robrwo/perl-Data-Enum)
and may be cloned from [git://github.com/robrwo/perl-Data-Enum.git](git://github.com/robrwo/perl-Data-Enum.git)

# BUGS

Please report any bugs or feature requests on the bugtracker website
[https://github.com/robrwo/perl-Data-Enum/issues](https://github.com/robrwo/perl-Data-Enum/issues)

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

## Reporting Security Vulnerabilities

Security issues should not be reported on the bugtracker website. Please see `SECURITY.md` for instructions how to
report security vulnerabilities

# AUTHOR

Robert Rothenberg <rrwo@cpan.org>

# COPYRIGHT AND LICENSE

This software is Copyright (c) 2021-2025 by Robert Rothenberg.

This is free software, licensed under:

```
The Artistic License 2.0 (GPL Compatible)
```
