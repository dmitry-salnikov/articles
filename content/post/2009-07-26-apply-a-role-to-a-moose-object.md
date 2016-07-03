---
date: 2009-07-26T00:00:00Z
summary: In which I show how to apply a role to a Moose's object
title: Apply a role to a Moose object
---

You can apply a role to a Moose object. You can do something like

```perl
#!/usr/bin/perl -w
use strict;
use feature ':5.10';

package foo;
use Moose::Role;
sub baz { 
    say 'i can haz baz'; 
}

package bar;
use Moose;
1;

package main;

my $test = bar->new;
say "i can't haz baz" if !$test->can("baz");

foo->meta->apply($test);
$test->baz;
```

with the following output:

```
i can't haz baz
i can haz baz
```
