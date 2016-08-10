This week, with [Alexi](http://www.sukria.net/fr/)'s help, [I've been working on](http://github.com/perldancer/Dancer) to add auto-(de)serialization to Dancer's request. This features will be available in the next [Dancer](http://perldancer.org/) version, the 1.170 (which will be out before April).

The basic idea was to provides to developer a simple way to access data that have been send in a serialized format, and to properly serialize the response.

At the moment, the supported serializers are :

Dancer  
Serialize::JSON

Dancer  
Serialize::YAML

Dancer  
Serialize::XML

Dancer  
Serialize::Mutable

## Configuring an application to use the serializer

To activate serialization in your application:

``` perl
set serializer => 'JSON';
```

or in your configuration file:

``` example
serializer: "JSON"
```

## A simple handler

Let's create a new dancer application (you can fetch the source on [my git server](http://git.lumberjaph.net/p5-dancer-rest.git/) :

``` bash
dancer -a dancerREST
cd dancerREST
vim dancerREST.pm
```

then

``` perl
package dancerREST;
use Dancer ':syntax';

my %users = ();

post '/api/user/' => sub {
    my $params = request->params;
    if ($params->{name} && $params->{id}) {
        if (exists $users{$params->{id}}) {
            return {error => "user already exists"};
        }
        $users{$params->{id}} = {name => $params->{name}};
        return {id => $params->{id}, name => $params->{name}};
    }
    else {
        return {error => "name is missing"};
    }
};

true;
```

We can test if everything works as expected:

``` bash
plackup app.psgi &
curl -H "Content-Type: application/json" -X POST http://localhost:5000/api/user/ -d '{"name":"foo","id":1}'
# => {"name":"foo","id":"1"}
```

Now we add a method to fetch a list of users, and a method to get a specific user:

``` perl
# return a specific user
get '/api/user/:id' => sub {
    my $params = request->params;
    if (exists $users{$params->{id}}) {
        return $users{$params->{id}};
    }
    else {
        return {error => "unknown user"};
    }
};

# return a list of users
get '/api/user/' => sub {
    my @users;
    push @users, {name => $users{$_}->{name}, id => $_}
        foreach keys %users;
    return \@users;
};
```

If we want to fetch the full list:

``` bash
curl -H "Content-Type: application/json" http://localhost:5000/api/user/
# => [{"name":"foo","id":"1"}]
```

and a specific user:

``` bash
curl -H "Content-Type: application/json" http://localhost:5000/api/user/1
# => {"name":"foo"}
```

## The mutable serializer

The mutable serializer will try to load an appropriate serializer guessing from the **Content-Type** and **Accept-Type** header. You can also overload this by adding a **content\_type=application/json** parameter to your request.

While setting your serializer to mutable, your let your user decide which format they prefer between YAML, JSON and XML.

## And the bonus

Dancer provides now a new method to the request object : `is_ajax`. Now you can write something like

``` perl
get '/user/:id' => sub {
    my $params = request->params;
    my $user   = $users{$params->{id}};
    my $result;
    if (!$user) {
        _render_user({error => "unknown user"});
    }
    else {
        _render_user($user);
    }
};

sub _render_user {
    my $result = shift;
    if (request->is_ajax) {
        return $result;
    }
    else {
        template 'user.tt', $result;
    }
}
```

If we want to simulate an AJAX query:

``` bash
curl -H "X-Requested-With: XMLHttpRequest" http://localhost:5000/user/1
```

and we will obtain our result in JSON. But we can also test without the X-Requested-With:

``` bash
curl http://localhost:5000/user/1
```

and the template will be rendered.

Hope you like this new features. I've also been working on something similar for [Tatsumaki](http://github.com/miyagawa/tatsumaki).
