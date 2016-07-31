## Net::Twitter

I've been asked for [$work](http://linkfluence.net) to write an API client for [backtype](http://www.backtype.com/), as we plan to integrate it in one of our services. A couple of days before I was reading the [Net::Twitter](http://search.cpan.org/perldoc?Net::Twitter) source code, and I've found interesting how [semifor](http://blog.questright.com/) wrote it.

Basically, what Net::Twitter does is this: for each API method, there is a `twitter_api_method` method, where the only code for this method is an API specification of the method. Let's look at the public timeline method:

```perl
twitter_api_method home_timeline => (
    description => <<'',
Returns the 20 most recent statuses, including retweets, posted by the
authenticating user and that user's friends. This is the equivalent of
/timeline/home on the Web.

    path     => 'statuses/home_timeline',
    method   => 'GET',
    params   => [qw/since_id max_id count page/],
    required => [],
    returns  => 'ArrayRef[Status]',
);
```

The `twitter_api_method` method is exported with Moose::Exporter. It generates a sub called `home_timeline` that is added to the class.

## MooseX::Net::API

As I've found this approch nice and simple, I thought about writing a [little framework](http://git.lumberjaph.net/p5-moosex-net-api.git/) to easily write API client this way. I will show how I've write a [client for the Backtype API](http://git.lumberjaph.net/p5-net-backtype.git/) using this (I've wrote some other client for private API at works too).

## Backtype API

First we defined our class:

```perl
package Net::Backtweet;
use Moose;
use MooseX::Net::API;
```

MooseX::Net::API export two methods: `net_api_declare` and `net_api_method`. The first method is for all the paramters that are common for each method. For Backtype, I'll get this:

```perl
net_api_declare backtweet => (
    base_url    => 'http://backtweets.com',
    format      => 'json',
    format_mode => 'append',
);
```

This set

* the base URL for the API
* the format is JSON
* some API use an extension at the name of the method to determine the format. "append" do this.

Right now three formats are supported: xml json and yaml. Two modes are supported: `append` and `content-type`.

Now the `net_api_method` method.

```perl
net_api_method backtweet_search => (
    path     => '/search',
    method   => 'GET',
    params   => [qw/q since key/],
    required => [qw/q key/],
    expected => [qw/200/],
);
```

* path: path for the method (required)
* method: how to acces this resource (GET POST PUT and DELETE are supported) (required)
* params: list of parameters to access this resource (required)
* required: which keys are required
* expected: list of HTTP code accepted

To use it:

```perl
my $backtype = Net::Bactype->new();
my $res =
    $backtype->backtweet_search(q => "http://lumberjaph.net", key => "foo");
warn Dump $res->{tweets};
```

## MooseX::Net::API implementation

Now, what is done by the framework. The `net_api_declare` method add various attributes to the class:

* api\_base_url: base URL of the API
* api_format: format for the query
* api\_format_mode: how the format is used (append or content-type)
* api_authentication: if the API requires authentication
* api_username: the username for accessing the resource
* api_password: the password
* api_authentication: does the resource requires to be authenticated

It will also apply two roles, for serialization and deserialization, unless you provides your own roles for this. You can provides your own method for useragent and authentication too (the module only do basic authentication).

For the `net_api_method` method, you can overload the authentication (in case some resources requires authentication).  You can also overload the default code generated.

In case there is an error, an MooseX::Net::API::Error will be throw.

## Conclusion

Right now, this module is not finished. I'm looking for suggestions (what should be added, done better, how I can improve stuff, ...). I'm not aiming to handle all possibles API, but at least most of the REST API avaible. I've uploaded a first version of
[MooseX::Net::API](http://search.cpan.org/perldoc?MooseX::Net::API) and [Net::Backtype](http://search.cpan.org/perldoc?Net::Backtype) on CPAN, and [the code](http://git.lumberjaph.net/p5-net-backtype.git/) is also [available on my git server](http://git.lumberjaph.net/p5-moosex-net-api.git/).
