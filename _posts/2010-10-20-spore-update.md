---
title: SPORE update
layout: post
summary: In which I share some update on SPORE.
---

As I've said [in my OSDC report](http://lumberjaph.net/conference/2010/10/12/osdcfr.html), after I [presented SPORE](http://www.slideshare.net/franckcuny/spore) I've had some positive feedback. In the last ten days, I've created a [google group](http://groups.google.com/group/spore-rest) to discuss the current specification and implementations, a [SPORE account on github](http://github.com/SPORE) to hold the implementation specifications and the API descriptions files, and more importantly, we have some new implementations: 

* [Ruby](http://github.com/sukria/Ruby-Spore)
* [node.js](http://github.com/francois2metz/node-spore)
* [Javascript](http://github.com/nikopol/jquery-spore) (client side)
* PHP (not published yet)

in addition to the already existing implementations:

* [Perl](http://github.com/franckcuny/net-http-spore)
* [Lua](http://github.com/fperrad/lua-Spore)
* [Clojure](http://github.com/ngrunwald/clj-spore)
* [Python](http://github.com/elishowk/pyspore)

In this post, I'll try to show some common usages for SPORE, in order to give a better explanation of why I think it's needed.

## Consistency

{% highlight lua %}
require 'Spore'
 
local github = Spore.new_from_spec 'github.json'
 
github:enable 'Format.JSON'
github:enable 'Runtime'
 
local r = github:user_information{format = 'json', username = 'schacon'}
 
print(r.status)               --> 200
print(r.headers['x-runtime']) --> 126ms
print(r.body.user.name)       --> Scott Chacon
{% endhighlight %}

{% highlight perl %}
use Net::HTTP::Spore;
 
my $gh = Net::HTTP::Spore->new_from_spec('github.json');
 
$gh->enable('Format::JSON');
$gh->enable('Runtime');
 
my $r= $gh->user_information( format => 'json', username => 'schacon' );
 
say "HTTP status => ".$r->status;                      # 200
say "Runtime     => ".$r->header('X-Spore-Runtime');   # 128ms
say "username    => ".$r->body->{user}->{name};        # Scott Chacon
{% endhighlight %}

{% highlight ruby %}
 
require 'spore'
 
gh = Spore.new(File.join(File.dirname(__FILE__), 'github.json'))
 
gh.enable(Spore::Middleware::Runtime)      # will add a header with runtime
gh.enable(Spore::Middleware::Format::JSON) # will deserialize JSON responses
 
# API call
r = gh.user_information( :format => 'json', :username => 'schacon' )
 
puts "HTTP status => ".r.code                        # 200
puts "Runtime     => ".r.header('X-Spore-Runtime')   # 128ms
puts "username    => ".r.body['user']['name']        # Scott Chacon
{% endhighlight %}

As you can see in the previous example, I do the same request on the GitHub API: fetch informations from the user "mojombo". In the three languages, the API for the client is the same:

* you create a client using the github.json API description
* you enable some middlewares
* you execute your request: the method name is the same, the argument names are the same!
* you manipulate the result the same way

## Easy to switch from a language to another

You can switch from a language to another without any surprises. If you must provide an API client to a third-party, you don't have to care about what languages they use, you only need to provide a description. Your methods call will be the same between all the languages, so it's easy to switch between languages, without the need to chose an appropriate client for your API (if one exists), to read the documentation (when there is one), and having the client implementation going in your way.

## Better maintanability

What annoys me the most when I want to use an API, is that I have to choose between two, three, or more clients that will communicate with this API. I need to read the documentations, the code, and test thoses implementations to decide which one will best fit my needs, and won't go in my way. And what if I need to do caching before the content is deserialized ? And what if the remote API changes it's authentication method (like twitter, from basic auth to OAuth) and the maintainer of the client doesn't update the code ?

With SPORE, you don't have to maintain a client, only a description file. Your API changes, all you have to do is to update your description, and all the clients, using any language, will be able to use your new API, without the need to release a new client specific for this API in javascript, Perl, Ruby, ...

## Easy to use with APIs that are compatible

If you want to use the Twitter public timeline:

{% highlight perl %}
use Net::HTTP::Spore;
 
my $client = Net::HTTP::Spore->new_from_spec('twitter.json');
 
$client->enable('Format::JSON');
 
my $r = $client->public_timeline( format => 'json' );
 
foreach my $t ( @{ $r->body } ) {
    my $username = Encode::encode_utf8( $t->{user}->{name} );
    my $text     = Encode::encode_utf8( $t->{text} );
    say $username . " says " . $text;
}
{% endhighlight %}

And now on statusnet:

{% highlight perl %}
use Net::HTTP::Spore;
 
my $client = Net::HTTP::Spore->new_from_spec(
  'twitter.json', 
   base_url => 'http://identi.ca/api'
);
 
$client->enable('Format::JSON');
 
my $r = $client->public_timeline( format => 'json' );
 
foreach my $t ( @{ $r->body } ) {
    my $username = Encode::encode_utf8( $t->{user}->{name} );
    my $text     = Encode::encode_utf8( $t->{text} );
    say $username . " says " . $text;
}
{% endhighlight %}

easy, right ? As both APIs are compatible, the only thing you need to do is change the argument **base_url** when you create your new client.

## It's easy to write a description

It's really easy to write a description for your API. Let's take a look at the
one for github:

{% highlight json %}
{
   "base_url" : "http://github.com/api/v2/",
   "version" : "0.2",
   "methods" : {
      "follow" : {
         "required_params" : [
            "user",
            "format"
         ],
         "path" : "/:format/user/follow/:user",
         "method" : "POST",
         "authentication" : true
      }
   },
   "name" : "GitHub",
   "authority" : "GITHUB:franckcuny",
   "meta" : {
      "documentation" : "http://develop.github.com/"
   }
}
{% endhighlight %}

The important parts are the basic API description (with a name, a base url for the API) and the list of available methods (here I've only put the 'follow' method).

More descriptions are available on [GitHub](http://github.com/SPORE/api-description), as well as and the [full specification](http://github.com/SPORE/specifications/blob/master/spore_description.pod).

We also have [a schema](http://github.com/SPORE/specifications/blob/master/spore_validation.rx) to validate your descriptions.

## Middlewares

By default, your SPORE client will only do a request and return a result. But it's easy to alter the default behavior with various middlewares. The most obvious one is the deserialization for a response, like the previous example with github and the middleware Format::JSON.

### Control your workflow

The use of middlewares allow you to control your workflow as with Plack/Rack/WSGI. You can easily imagine doing this:

* check if the request has already been made and cached
* return the response if the cache is still valid
* perform the request
* send the content to a remote storer in raw format
* cache the raw data locally
* deserialize to json
* remove some data from the response
* give the response to the client

Or to interrogate a site as an API:

* send a request on a web page
* pass the response to a scraper, and put the data in JSON
* return the JSON with scraped data to the client

### Creating a repository on GitHub

In this example, we use a middleware to authenticate on the GitHub API:

{% highlight perl %}
use Config::GitLike;
use Net::HTTP::Spore;
 
my $c = Config::GitLike::Git->new(); $c->load;
 
my $login = $c->get(key => 'github.user');
my $token = $c->get(key => 'github.token');
 
my $github = Net::HTTP::Spore->new_from_spec('github.json');
 
$github->enable('Format::JSON');
$github->enable(
    'Auth::Basic',
    username => $login . '/token',
    password => $token,
);
 
my $res = $github->create_repo(
    format  => 'json', 
    payload => {name => $name, description => $desc}
);
{% endhighlight %}

The middleware Auth::Basic will add the **authorization** header to the request, using the given tokens.

### SPORE + MooseX::Role::Parameterized

I really like [MooseX::Role::Parameterized](http://search.cpan.org/perldoc?MooseX::Role::Parameterized). This module allows you to build dynamically a Role to apply to your class/object: 

{% highlight perl %}
package My::App::Role::SPORE;                                                                                                                                                            
                                                                                                                                                                                               
use MooseX::Role::Parameterized;                                                                                                                                                               
use Net::HTTP::Spore;                                                                                                                                                                          
                                                                                                                                                                                               
parameter name => ( isa	=> 'Str', required => 1, );                                                                    	                                                                       
                                                                                                                                                                                               
role {                                                                                                                                                                                         
    my $p    = shift;                                                                                                                                                                          
    my $name = $p->name;                                                                                                                                                                       
                                                                                                                                                                                               
    has $name => (                          	                                                                                                                                               
        is     	=> 'rw',                                                                                                                                                                       
        isa 	=> 'Object',                                                                    	   	                                                                               
        lazy	=> 1,                                                                                                                  	                                                       
        default	=> sub {                                                                                                                                                                       
            my $self          = shift;                                                                                                                                                         
            my $client_config = $self->context->{spore}->{$name};                                                                                                                              
            my $client        = Net::HTTP::Spore->new_from_spec(                                                                                                                               
           	$client_config->{spec},                                                                                                                                                        
                %{ $client_config->{options} },                                                                                                                                                
            );                                                                                                                                                                                 
            foreach my $mw ( @{ $client_config->{middlewares} } ) {                                                                                                                            
             	$client->enable($mw);                                                                                                                                                          
            }                                                                                                                                                                                  
        },                                                                                                                                                                                     
    );                                                                                                                                                                                         
};                                                                                                                                                                                             
                                                                                                                                                                                               
1;   
 
# in your app
 
package My::App;
 
use Moose;
 
with 'My::App::Role::SPORE' => { name => 'couchdb' }, 
     'My::App::Role::SPORE' => { name => 'url_solver' };
 
1;
{% endhighlight %}

This Role will add two new attributes to my class: **couchdb** and **url_solver**, reading from a config file a list of middlewares to apply and the options (like base_uri).

## Testing my application that uses CouchDB

This is a common case. In your application you use CouchDB to store some information. When you run the tests for this application, you don't know if there will be a couchdb running on the host, if it will be on the default port, on what database should you do your tests, ...

The Perl implementation of SPORE comes with a Mock middleware:

{% highlight perl %}
package myapp;
 
use Moose;
has couchdb_client => (is => 'rw', isa => 'Object');

use Test::More;
use JSON;
 
use myapp;
 
use Net::HTTP::Spore;
 
my $content = { title => "blog post", website => "http://lumberjaph.net" };
 
my $mock_server = {
    '/test_database/1234' => sub {
        my $req = shift;
        $req->new_response(
            200,
            [ 'Content-Type' => 'application/json' ],
            JSON::encode_json($content)
        );
    },
};
 
ok my $client =
  Net::HTTP::Spore->new_from_spec(
      '/home/franck/code/projects/spore/specifications/apps/couchdb.json',
    base_url => 'http://localhost:5984' );
 
$client->enable('Format::JSON');
$client->enable( 'Mock', tests => $mock_server );
 
my $app = myapp->new(couchdb_client => $client);
 
my $res =
  $app->client->get_document( database => 'test_database', doc_id => '1234' );
is $res->[0],        200;
is_deeply $res->[2], $content;
is $res->header('Content-Type'), 'application/json';
 
done_testing;

{% endhighlight %}

The middleware catches the request, checks if it matches something defined by the user and returns a response. 

## So ...

I really see SPORE as something Perlish: a glue. The various implementations are a nice addition, and I'm happy to see some suggestions and discussions about the specifications.

I'm pretty confident that the current specification for the API description is stable at this point. We still need to write more middlewares to see if we can cover most of the usages easily, so we can decide if the specification for the implementation is valid.

(as always, thanks to bl0b!).
