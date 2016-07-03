---
date: 2010-04-03T00:00:00Z
summary: In which I have fun with Tatsumaki.
title: More fun with Tatsumaki and Plack
---

Lately I've been toying a lot with [Plack](http://plackperl.org/) and two Perl web framework: [Tatsumaki](http://search.cpan.org/perldoc?Tatsumaki) and [Dancer](http://search.cpan.org/perldoc?Dancer). I use both of them for different purposes, as their features complete each other.

## Plack

If you don't already know what Plack is, you would want to take a look at the following Plack resources:

* [Plack (redesigned) website](http://plackperl.org)
* [Plack documentation](http://search.cpan.org/perldoc?Plack)
* [Miyagawa's screencast](http://bulknews.typepad.com/blog/2009/11/plack-and-psgi-screencast-and-feedbacks.html)
* [Plack advent calendar](http://advent.plackperl.org/)

> As [sukria](http://www.sukria.net/) is planning to talk about [Dancer](http://perldancer.org) during the [FPW 2010](http://journeesperl.fr/fpw2010/index.html), I will probably do a talk about Plack.

After reading some code, I've started to write two middleware: the first one add ETag header to the HTTP response, and the second one provides a way to limit access to your application.

### Plack::Middleware::ETag

This middleware is really simple: for each request, an [ETag](http://en.wikipedia.org/wiki/HTTP_ETag) header is added to the response. The ETag value is a sha1 of the response's content. In case the content is a file, it works like apache, using various information from the file: inode, modified time and size. This middleware can be used with [Plack::Middleware::ConditionalGET](http://search.cpan.org/perldoc?Plack::Middleware::ConditionalGET), so the client will have the ETag information for the page, and when he will do a request next time, it will send an "if-modified" header. If the ETag is the same, a 304 response will be send, meaning the content have not been modified. This module is [available on CPAN](http://search.cpan.org/perldoc?Plack::Middleware::ETag).

Let's see how it works. First, we create a really simple application (we call it app.psgi):

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use Plack::Builder;

builder {
    enable "Plack::Middleware::ConditionalGET";
    enable "Plack::Middleware::ETag";
    sub {
        ['200', ['Content-Type' => 'text/html'], ['Hello world']];
    };
};
```

Now we can test it:

```bash
% plackup app.psgi&
% curl -D - http://localhost:5000
HTTP/1.0 200 OK
Date: Sat, 03 Apr 2010 09:31:43 GMT
Server: HTTP::Server::PSGI
Content-Type: text/html
ETag: 7b502c3a1f48c8609ae212cdfb639dee39673f5e
Content-Length: 11

% curl -H "If-None-Match: 7b502c3a1f48c8609ae212cdfb639dee39673f5e" -D - http://localhost:5000
HTTP/1.0 304 Not Modified
Date: Sat, 03 Apr 2010 09:31:45 GMT
Server: HTTP::Server::PSGI
ETag: 7b502c3a1f48c8609ae212cdfb639dee39673f5e
```

### Plack::Middleware::Throttle

[With this middleware](http://git.lumberjaph.net/p5-plack-middleware-throttle.git/), you can control how many times you want to provide an access to your application. This module is not yet on CPAN, has I want to add some features, but you can get the code from git. There is four methods to control access:

* Plack::Middleware::Throttle::Hourly: how many times in one hour someone can access the application
* P::M::T::Daily: the same, but for a day
* P::M::T::Interval: which interval the client must wait between two query
* by combining the three previous methods

To store sessions informations, you can use any cache backend that provides `get`, `set` and `incr` methods. By default, if no backend is provided, it will store informations in a hash. You can easily modify the defaults throttling strategies by subclassing all the classes.

Let's write another application to test it:

```perl
#!/usr/bin/env perl
use strict;
use warnings;
use Plack::Builder;

builder {
    enable "Plack::Middleware::Throttle::Hourly", max => 2;
    sub {
        ['200', ['Content-Type' => 'text/html'], ['Hello world']];
    };
};
```

then test

```bash
% curl -D - http://localhost:5000/
HTTP/1.0 200 OK
Date: Sat, 03 Apr 2010 09:57:40 GMT
Server: HTTP::Server::PSGI
Content-Type: text/html
X-RateLimit-Limit: 2
X-RateLimit-Remaining: 1
X-RateLimit-Reset: 140
Content-Length: 11

Hello world

% curl -D - http://localhost:5000/
HTTP/1.0 200 OK
Date: Sat, 03 Apr 2010 09:57:40 GMT
Server: HTTP::Server::PSGI
Content-Type: text/html
X-RateLimit-Limit: 2
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 140
Content-Length: 11

Hello world

% curl -D - http://localhost:5000/
HTTP/1.0 503 Service Unavailable
Date: Sat, 03 Apr 2010 09:57:41 GMT
Server: HTTP::Server::PSGI
Content-Type: text/plain
X-RateLimit-Reset: 139
Content-Length: 15

Over rate limit
```

Some HTTP headers are added to the response :

* **X-RateLimit-Limit**: how many request can be done
* **X-RateLimit-Remaining**: how many requests are available
* **X-RateLimit-Reset**: when will the counter be reseted (in seconds)

This middleware could be a very good companion to the [Dancer REST stuff](http://www.sukria.net/fr/archives/2010/03/19/let-the-dancer-rest/) [added recently](/easily-create-rest-interface-with-the-dancer-1.170/).

## another Tatsumaki application with Plack middlewares

To demonstrate the use of this two middleware, [I wrote a small application](http://git.lumberjaph.net/p5-feeddiscovery.git/) with Tatsumaki. This application fetch a page, parse it to find all the feeds declared, and return a JSON with the result.

```bash
% GET http://feeddiscover.tirnan0g.org/?url=http://lumberjaph.net/blog/
```

will return

```javascript
% [{"href":"http://lumberjaph.net/blog/index.php/feed/","type":"application/rss+xml","title":"i'm a lumberjaph RSS Feed"}]
```

This application is composed of one handler, that handle only **GET** request. The request will fetch the url given in the **url** parameter, scrap the content to find the links to feeds, and cache the result with Redis. The response is a JSON string with the informations.

The interesting part is the app.psgi file:

```perl
my $app = Tatsumaki::Application->new(['/' => 'FeedDiscovery::Handler'],);

builder {
    enable "Plack::Middleware::ConditionalGET";
    enable "Plack::Middleware::ETag";
    enable "Plack::Middleware::Throttle::Hourly",
        backend => Redis->new(server => '127.0.0.1:6379',),
        max     => 100;
    $app;
};
```

The application itself is really simple: for a given url, the Tatsumaki::HTTPClient fetch an url, I use [Web::Scraper](http://search.cpan.org/perldoc?Web::Scraper) to find the **link rel="alternate"** from the page, if something is found, it's stored in Redis, then a JSON string is returned to the client.
