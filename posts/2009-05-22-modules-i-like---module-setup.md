[Module::Setup](http://search.cpan.org/perldoc?Module::Setup) by [Yappo](http://blog.yappo.jp/) is a really nice module. I don't like [Module::Starter](http://search.cpan.org/perldoc?Module::Starter), it's not easy to create template to make it do what you need. With Module::Setup you can create flavors for any type of modules you want. Most of the modules I create for work use Moose, and I like to use Test::Class too. I've created a Moose flavor for creating this kind of modules.

### Creating a Moose flavor for Module::Setup

First, you tell it to init a new flavor:

```bash
module-setup --init moose
```

Module::Setup ask what is your favorite SCM. For me, it's git. It will create files in *$HOME/.module-setup/flavors/moose/*.

Start by editing *$HOME/.module-setup/flavors/moose/template/lib/____var-module_path-var____.pm* to make it look like this

```perl
- use strict;
- use warnings;
+ use Moose;
```

Add **requires 'Moose'** in **Makefile.PL**. Create a **t/tests/Test/____var-module_path-var____.pm** file with the following content:

```perl
package Test :: [%module %];

use strict;
use warnings;
use base 'Test::Class';
use Test::Exception;
use Test::More;

sub class {'[% module %]'}

sub startup : Tests(startup => 1) {
    my $test = shift;
    use_ok $test->class, "use ok";
}

sub shutdown : Tests(shutdown) {
    my $test = shift;
}

sub constructor : Tests(1) {
    my $test = shift;
    can_ok $test->class, 'new';
}

1;
```

You will have a Test::Class test ready with basic tests already implemented.

If you want to share this template at $work, easy:

```bash
module-setup --pack DevMoose moose > DevMoose.pm
```

You just have to send DevMoose.pm to who need it, and he will be able to import it with

```bash
module-setup --init --flavor-class=+DevMoose moose
```

Now you can create a new module

```bash
module-setup MY::AWESOME::MODULE moose
```
