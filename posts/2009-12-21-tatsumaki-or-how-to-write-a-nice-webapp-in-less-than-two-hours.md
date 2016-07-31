Until today, I had a script named "lifestream.pl". This script was triggered via cron once every hour, to fetch various feeds from services I use (like <a href="http://github.com/">github</a>, <a href="http://identi.ca/">identi.ca</a>, ...) and to process the result through a template and dump the result in a HTML file.

Today I was reading <a href="http://github.com/miyagawa/Tatsumaki">Tatsumaki's code</a> and some examples (<a href="http://github.com/gugod/Social">Social</a> and <a href="http://github.com/miyagawa/Subfeedr">Subfeedr</a>). Tatsumaki is a "port" <a href="http://www.tornadoweb.org/">tornado</a> (a non blocking server in Python), based on Plack and AnyEvent. I though that using this to replace my old lifestream script would be a good way to test it. Two hours later I have a complete webapp that works (and the code is available <a href="http://git.lumberjaph.net/p5-lifestream.git/">here</a>).

The code is really simple: first, I define an handler for my HTTP request. As I have only one things to do (display entries), the handler is really simple:

```perl
package Lifestream::Handler;
use Moose;
extends 'Tatsumaki::Handler';

sub get {
    my $self   = shift;
    my %params = %{$self->request->params};
    $self->render(
        'lifestream.html',
        {   memes    => $self->application->memes($params{page}),
            services => $self->application->services
        }
    );
}
1;
```

For all the get request, 2 methods are called : <strong>memes</strong> and <strong>services</strong>. The <strong>memes</strong> get a list of memes to display on the page. The services get the list of the various services I use (to display them on a sidebar).

Now, as I don't want to have anymore my lifestream.pl script in cron, I will let Tatsumaki do the polling. For this, I add a service to my app, which is just a worker.

```perl
package Lifestream::Worker;
use Moose;
extends 'Tatsumaki::Service';
use Tatsumaki::HTTPClient;

sub start {
    my $self = shift;
    my $t;
    $t = AE::timer 0, 1800, sub {
        scalar $t;
        $self->fetch_feeds;
    };
}

sub fetch_feeds {
    my ($self, $url) = @_;
    Tatsumaki::HTTPClient->new->get(
        $url,
        sub {
            #do the fetch and parsing stuff
        }
    );
}
```

From now, every 60 minutes, feeds will be checked. Tatsumaki::HTTPClient is a HTTP client based on AnyEvent::HTTP.

Let's write the app now

```perl
package Lifestream;

use Moose;
extends "Tatsumaki::Application";

use Lifestream::Handler;
use Lifestream::Worker;

sub app {
    my ($class, %args) = @_;
    my $self = $class->new(['/' => 'Lifestream::Handler',]);
    $self->config($args{config});
    $self->add_service(Lifestream::Worker->new(config => $self->config));
    $self;
}

sub memes {
}

sub services {
}
```

The <strong>memes</strong> and <strong>services</strong> method called from the handler are defined here. In the app method, I "attch" the "/" path to the handler, and I add the service.

and to launch the app

```perl
my $app = Lifestream->app(config => LoadFile($config));
require Tatsumaki::Server;
Tatsumaki::Server->new(
    port => 9999,
    host => 0,
)->run($app);
```

And that's it, I now have a nice webapp, with something like only 200 LOC. I will keep playing with <a href="http://www.slideshare.net/miyagawa/tatsumaki">Tatsumaki</a> as I have more ideas (and probably subfeedr too). Thanks to <a href="http://bulknews.typepad.com/">miyagawa</a> for all this code.
