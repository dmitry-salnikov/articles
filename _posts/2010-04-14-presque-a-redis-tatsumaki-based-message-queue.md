---
layout: post
summary: In which I introduce presque
title: presque, a Redis / Tatsumaki based message queue
---

[presque](http://github.com/franckcuny/presque/tree/) is a small message queue service build on top of [redis](http://code.google.com/p/redis/) and [Tatsumaki](http://search.cpan.org/perldoc?Tatsumaki). It's heavily inspired by [RestMQ](http://github.com/gleicon/restmq) and [resque](http://github.com/defunkt/resque).

* Communications are done in JSON over HTTP
* Queues and messages are organized as REST resources
* A worker can be writen in any language that make a HTTP request and read JSON
* Thanks to redis, the queues are persistent

## Overview

resque need a configuration file, writen in YAML that contains the host and port for the Redis server.

{% highlight yaml %}
redis:
    host: 127.0.0.1
    port: 6379
{% endhighlight %}

Let's start the server:

{% highlight bash %}
% plackup app.psgi --port 5000
{% endhighlight %}

The applications provides some HTTP routes:

* **/**: a basic HTML page with some information about the queues
* **/q/**: REST API to get and post job to a queue
* **/j/**: REST API to get some information about a queue
* **/control/**: REST API to control a queue (start or stop consumers)
* **/stats/**: REST API to fetch some stats (displayed on the index page)

Queues are created on the fly, when a job for an unknown queue is inserted. When a new job is created, the JSON send in the POST will be stored "as is". There is no restriction on the schema or the content of the JSON.

Creating a new job simply consist to :

{% highlight bash %}
% curl -X POST "http://localhost:5000/q/foo" -d '{"foo":"bar", "foo2":"bar" }'
{% endhighlight %}

and fetching the job:

{% highlight bash %}
% curl "http://localhost:5000/q/foo"
{% endhighlight %}

When a job is fetched, it's removed from the queue.

## A basic worker

I've also pushed [presque::worker](http://git.lumberjaph.net/p5-presque-worker.git/). It's based on [AnyEvent::HTTP](http://search.cpan.org/perldoc?AnyEvent::HTTP) and [Moose](http://search.cpan.org/perldoc?Moose). Let's write a basic worker using this class:

{% highlight perl %}
use strict;
use warnings;
use 5.012;    # w00t

package simple::worker;
use Moose;
extends 'presque::worker';

sub work {
    my ($self, $job) = @_;
    say "job's done";
    ...;      # yadda yadda!
    return;
}

package main;
use AnyEvent;

my $worker =
    simple::worker->new(base_uri => 'http://localhost:5000', queue => 'foo');

AnyEvent->condvar->recv;
{% endhighlight %}

A worker have to extends the presque::worker class, and implement the method *work*. When the object is created, the class check if this method is avalaible. You can also provide a `fail` method, which will be called when an error occur.

## The future

I plan to add support for [websocket](http://en.wikipedia.org/wiki/WebSocket), and probably [XMPP](http://en.wikipedia.org/wiki/Xmpp). More functionalities to the worker too: logging, forking, handling many queues, ... I would like to add priorities to queue also, and maybe scheluding job for a given date (not sure if it's feasable with Redis).
