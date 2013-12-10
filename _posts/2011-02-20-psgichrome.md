---
layout: post
summary: In which I show how to log from a PSGI app to Chrome.
title: PSGIChrome
---

Earlier this month, I've read about this extension: [chromePHP](http://www.chromephp.com/).

The principle of this extension is to allow you to log from your PHP application to chrome. You may not be aware, but this is something you already have with every web application if you're using Plack. And not only for Chrome, but every webkit navigator, and Firefox too!

Let's mimic their page.

## Installation

1. install [Plack::Middleware::ConsoleLogger](http://search.cpan.org/perldoc?Plack::Middleware::ConsoleLogger) (`cpanm Plack::Middleware::ConsoleLogger`)
2. no step 2
3. no step 3
4. write a simple PSGI application and log

{% highlight perl %}
use strict;
use warnings;

use Plack::Builder;

my $app = sub {
  my $env     = shift;
  my $content = "<html><body>this is foo</body></html>";
  foreach my $k ( keys %$env ) {
    if ( $k =~ /HTTP_/ ) {
      $env->{'psgix.logger'}->({
        level   => 'debug',
        message => "$k => " . $env->{$k},
      });
    }
  }
  $env->{'psgix.logger'}->({
    level => 'warn',
    message => 'this is a warning',
  });
  $env->{'psgix.logger'}->({
    level => 'error',
    message => 'this is an error',
  });
  return [ 200, [ 'Content-Type' => 'text/html' ], [$content] ];
};

builder {
  enable "ConsoleLogger";
  $app;
}
{% endhighlight %}

Load this application with plackup: `plackup chromeplack.pl`

point your browser to http://localhost:5000, activate the javascript console.

If this works correctly, you should have a smiliar output in your console:

<img src="/static/imgs/plack_chrome.png" />

## Dancer

I don't know for other framework, but you can also log to your browser with [Dancer](http://perldancer.org/).

First, you need to install [Dancer::Logger::PSGI](http://search.cpan.org/perldoc?Dancer::Logger::PSGI), then, in your application, you need to edit the environment file. You'll certainly want to change 'development.yml'.

{% highlight yaml %}
logger: "PSGI"
plack_middlewares:
  -
    - ConsoleLogger
{% endhighlight %}

Now you can start your application (running in a Plack environment, of course), and next time you'll use 'warning' or 'debug' or any other keyword from Dancer::Logger, the message will end up in your javascript console.
