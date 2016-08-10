As I was looking for a system to store documents at $work, Riak was pointed to me by one of my coworkers. I'm looking for a solution of this type to store various types of documents, from HTML pages to json. I need a system that is distributed, faul tolerant, and that works with Perl.

So Riak is a document based database, it's key value, no sql, REST, and in Erlang. You can read more about it here or watch an introduction here. Like &lt;ahref="<http://couchdb.apache.org/>"&gt;CouchDB, Riak provides a REST interface, so you don't have to write any Erlang code.

One of the nice things with Riak it's that it let you defined the N, R and W value for each operation. This values are:

-   N: the number of replicas of each value to store
-   R: the number of replicas required to perform a read operation
-   W: the number of replicas needed for a write operation

Riak comes with library for python ruby PHP and even javascript, but not for Perl. As all these libraries are just communicating with Riak via the REST interface, I've started to write one using AnyEvent::HTTP, and also a backend for KiokuDB.

## Installing and using Riak

If you interested in Riak, you can install it easily. First, you will need the Erlang VM. On debian, a simple

``` bash
sudo aptitude install erlang
```

install everything you need. Next step is to install Riak:

``` bash
wget http://hg.basho.com/riak/get/riak-0.6.2.tar.gz
tar xzf riak-0.6.2.tar.gz
cd riak
make
export RIAK=`pwd`
```

Now, you can start to use it with

``` bash
/start-fresh config/riak-demo.erlenv
```

or if you want to test it in cluster mode, you can write a configuration like this:

``` erlang
{cluster_name, "default"}.
{ring_state_dir, "priv/ringstate"}.
{ring_creation_size, 16}.
{gossip_interval, 60000}.
{storage_backend, riak_fs_backend}.
{riak_fs_backend_root, "/opt/data/riak/"}.
{riak_cookie, riak_demo_cookie}.
{riak_heart_command, "(cd $RIAK; ./start-restart.sh $RIAK/config/riak-demo.erlenv)"}.
{riak_nodename, riakdemo}.
{riak_hostname, "192.168.0.11"}.
{riak_web_ip, "192.168.0.11"}.
{riak_web_port, 8098}.
{jiak_name, "jiak"}.
{riak_web_logdir, "/tmp/riak_log"}.
```

Copy this config on a second server, edit it to replace the riak\_hostname and riak\_nodename. On the first server, start it like show previously, then on the second, with

``` bash
./start-join.sh config/riak-demo.erlenv 192.168.0.11
```

where the IP address it the address of the first node in your cluster.

Let's check if everything works:

``` bash
% curl -X PUT -H "Content-type: application/json" \
    http://192.168.0.11:8098/jiak/blog/lumberjaph/ \
    -d "{\"bucket\":\"blog\",\"key\":\"lumberjaph\",\"object\":{\"title\":\"I'm a lumberjaph, and I'm ok\"},\"links\":[]}"

% curl -i http://192.168.0.11:8098/jiak/blog/lumberjaph/
```

will output (with the HTTP blabla)

``` json
{"object":{"title":"I'm a lumberjaph, and I'm ok"},"vclock":"a85hYGBgzGDKBVIsbGubKzKYEhnzWBlCTs08wpcFAA==","lastmod":"Sun, 13 Dec 2009 20:28:04 GMT","vtag":"5YSzQ7sEdI3lABkEUFcgXy","bucket":"blog","key":"lumberjaph","links":[]}
```

## Using Riak with Perl and KiokuDB

I need to store various things in Riak: html pages, json data, and objects using KiokuDB. I've started to write a client for Riak with AnyEvent, so I can do simple operations at the moment, (listing information about a bucket, defining a new bucket with a specific schema, storing, retriving and deleting documents). To create a client, you need to

``` perl
my $client = AnyEvent::Riak->new(
    host => 'http://127.0.0.1:8098',
    path => 'jiak',
);
```

As Riak exposes to you it's N, R, and W value, you can also set them in creation the client:

``` perl
my $client = AnyEvent::Riak->new(
    host => 'http://127.0.0.1:8098',
    path => 'jiak',
    r    => 2,
    w    => 2,
    dw   => 2,
);
```

where:

-   the W and DW values define that the request returns as soon as at least W nodes have received the request, and at least DW nodes have stored it in their storage backend.
-   with the R value, the request returns as soon as R nodes have responded with a value or an error. You can also set this values when calling fetch, store and delete. By default, the value is set to 2.

So, if you wan to store a value, retrieve it, then delete it, you can do:

``` perl
my $store =
    $client->store({bucket => 'foo', key => 'bar', object => {baz => 1},})
    ->recv;
my $fetch = $client->fetch('foo', 'bar')->recv;
my $delete = $client->delete('foo', 'bar')->recv;
```

If there is an error, the croak method from AnyEvent is used, so you may prefer to do this:

``` perl
use Try::Tiny;
try {
    my $fetch = $client->fetch('foo', 'baz')->recv;
}
catch {
    my $err = decode_json $_;
    say "error: code => " . $err->[0] . " reason => " . $err->[1];
};
```

The error contains an array, with the first value the HTTP code, and the second value the reason of the error given by Riak.

At the moment, the KiokuDB backend is not complete, but if you want to start to play with is, all you need to do is:

``` perl
my $dir = KiokuDB->new(
    backend => KiokuDB::Backend::Riak->new(
        db => AnyEvent::Riak->new(
            host => 'http://localhost:8098',
            path => 'jiak',
        ),
        bucket => 'kiokudb',
    ),
);

$dir->txn_do(sub { $dir->insert($key => $object) });
```
