---
date: 2009-05-18T00:00:00Z
summary: In which we had one more article on how to write a feed aggregator.
title: A simple feed aggregator with modern Perl - part 4.1
---

You can thanks [bobtfish](http://github.com/bobtfish) for being such a pedantic guy, 'cause now you will have a better chained examples. He forked my repository from GitHub and fix some code that I'll explain here.

### lib/MyFeedReader.pm

```perl
 package MyFeedReader;
+use Moose;
+use namespace::autoclean;

-use strict;
-use warnings;
-
-use Catalyst::Runtime '5.70';
+use Catalyst::Runtime '5.80';

-use parent qw/Catalyst/;
+extends 'Catalyst';
```

You can see that he use [Moose](http://search.cpan.org/perldoc?Moose), so we can remove

```perl
use strict;
use warnings;
```

and have a more elegant way to inherit from [Catalyst](http://search.cpan.org/perldoc?Catalyst) with

```perl
extends 'Catalyst';
```

instead of

```perl
use parent qw/Catalyst/;
```

He also have updated the **Catalyst::Runtime** version, and added **namespace::autoclean**. The purpose of this module is to keep imported methods out of you namespace. Take a look at the "documentation":http://search.cpan.org/perldoc?namespace::autoclean, it's easy to understand how and why it's usefull.

### lib/MyFeedReader/Controller/Root.pm

```perl
-use strict;
-use warnings;
-use parent 'Catalyst::Controller';
+use Moose;
+use namespace::autoclean;
+BEGIN { extends 'Catalyst::Controller' }

-sub index :Path :Args(0) {
+sub root : Chained('/') PathPart() CaptureArgs(0) {}
+
+sub index : Chained('root') PathPart('') Args(0) {
        my ( $self, $c ) = @_;

        # Hello World
        $c->response->body( $c->welcome_message );
    }

-sub default :Path {
+sub default : Private {
        my ( $self, $c ) = @_;
        $c->response->body( 'Page not found' );
        $c->response->status(404);
```

A new method, `root`, that will be the root path for our application. All our methods will be chained from this action. If start you catalyst server and go to **http://localhost:3000/** you will be served with the Catalyst's welcome message as before.

### lib/MyFeedReader/Controller/Entry.pm

```perl
-use warnings;
+use Moose;
 use MyAggregator::Entry;
-use parent 'Catalyst::Controller';
-
-__PACKAGE__->config->{namespace} = 'entry';
+use namespace::autoclean;
+BEGIN { extends 'Catalyst::Controller'; }

-sub view : Chained('/') : PathPart('entry') : Args(1) {
+sub view : Chained('/root') : PathPart('entry') : Args(1) {
     my ( $self, $c, $id ) = @_;

     $c->stash->{entry} = $c->model('KiokuDB')->lookup($id);
 }

-1;
-
+__PACKAGE__->meta->make_immutable;
```

We extends the **Catalyst::Controller** in a Moose way, and the `make_immutable` instruction is a Moose recommanded best practice (you can alsa add `no Moose` after the make_immutable).

### lib/MyFeedreader/Controller/Feed.pm

```perl
+use Moose;
+use namespace::autoclean;
+BEGIN { extends 'Catalyst::Controller' }

-use strict;
-use warnings;
-use parent 'Catalyst::Controller';
+sub feed : Chained('/root') PathPart('feed') CaptureArgs(0) {}

-__PACKAGE__->config->{namespace} = 'feed';
-
-sub index : Path : Args(0) {
+sub index : Chained('feed') PathPart('') Args(0) {
     my ( $self, $c ) = @_;

     $c->stash->{feeds}
         = [ $c->model('MyModel')->resultset('Feed')->search() ];
 }

-sub view : Chained('/') : PathPart('feed/view') : Args(1) {
+sub view : Chained('feed') : PathPart('view') : Args(1) {
     my ( $self, $c, $id ) = @_;

     $c->stash->{feed}
         = $c->model('MyModel')->resultset('Feed')->find($id);
 }

-1;
+__PACKAGE__->meta->make_immutable;
```

We got `feed` which is chained to root. `index` is chained to feed, and take no arguments. This method display the list of our feeds. And we got the `view` method, chained to feed too, but with one argument, that display the content of an entry.

If you start the application, you will see the following routes:


    .-------------------------------------+--------------------------------------.
    | Path Spec                           | Private                              |
    +-------------------------------------+--------------------------------------+
    | /root/entry/*                       | /root (0)                            |
    |                                     | => /entry/view                       |
    | /root/feed                          | /root (0)                            |
    |                                     | -> /feed/feed (0)                    |
    |                                     | => /feed/index                       |
    | /root/feed/view/*                   | /root (0)                            |
    |                                     | -> /feed/feed (0)                    |
    |                                     | => /feed/view                        |
    | /root                               | /root (0)                            |
    |                                     | => /index                            |
    '-------------------------------------+--------------------------------------'

I hope you got a better idea about chained action in catalyst now. And again, thanks to bobtfish for the code.
