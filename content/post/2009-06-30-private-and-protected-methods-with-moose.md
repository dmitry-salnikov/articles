---
date: 2009-06-30T00:00:00Z
summary: In which I show how to write dummy private methods for Moose
title: Private and protected methods with Moose
---

Yesterday, one of our interns asked me a question about private method in <a href="http://www.iinteractive.com/moose/">Moose</a>. I told him that for Moose as for Perl, there is no such things as private method. By convention, methods prefixed with '_' are considered private.

But I was curious to see if it would be something complicated to implement in Moose. First, I've started to look at how the 'augment' keyword is done. I've then hacked Moose directly to add the private keyword. After asking advice to <a href="http://blog.woobling.org/">nothingmuch</a>, he recommended me that I implement this in a MooseX::* module instead. The result is <a href="http://git.lumberjaph.net/p5-moosex-methodprivate.git/">here</a>.

From the synopsis, MooseX::MethodPrivate do:

```perl
package Foo;
use MooseX::MethodPrivate;

private 'foo' => sub {
};

protected 'bar' => sub {
};


my $foo = Foo->new;
$foo->foo;    # die, can't call foo because it's a private method
$foo->bar;    # die, can't call bar because it's a protected method

package Bar;
use MooseX::MethodPrivate;
extends qw/Foo/;

sub baz {
    my $self = shift;
    $self->foo;    #die, can't call foo because it's a private method
    $self->bar;    # ok, can call this method because we extends Foo and
    # it's a protected method
}
```

I was surprised to see how easy it's to extend Moose syntax. All I've
done was this:

```perl
    Moose::Exporter->setup_import_methods(
        with_caller => [qw( private protected )],);
```

and write the `private` and `protected` sub. I'm sure there is some stuff I can do to improve this, but for a first test, I'm happy with the result and still amazed how easy it was to add this two keywords.
