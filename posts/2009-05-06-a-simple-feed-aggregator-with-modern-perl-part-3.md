Now that we have our aggregator, we have to write our tests. For this I will use Test::Class. Ovid have wrote an [excellent](http://www.modernperlbooks.com/mt/2009/03/organizing-test-suites-with-testclass.html) [serie](http://www.modernperlbooks.com/mt/2009/03/reusing-test-code-with-testclass.html) [of](http://www.modernperlbooks.com/mt/2009/03/making-your-testing-life-easier.html) [articles](http://www.modernperlbooks.com/mt/2009/03/using-test-control-methods-with-testclass.html) [about Test::Class](http://www.modernperlbooks.com/mt/2009/03/working-with-testclass-test-suites.html). You should really read this, because I will not enter in details.

We have two things to test:

-   roles
-   aggregator

### Roles

For this, we create the following files:

-   t/tests/Test/TestObject.pm
-   t/tests/Test/MyRoles.pm
-   t/tests/Test/MyAggregator.pm
-   t/run.t

We will write our **run.t**:

``` perl
use lib 't/test';
use Test::MyRoles;
Test::Class->runtests;
```

this test load our tests and run them.

This is a just a class for the tests, that load our 2 roles.

now the roles' tests:

``` perl
package Test::MyRoles;

use strict;
use warnings;
use base 'Test::Class';
use Test::Exception;
use Test::More;

sub class {'Test::TestObject'}

sub url {"http://lumberjaph.net/blog/index.php/feed/"}

sub startup : Tests(startup => 1) {
    my $test = shift;
    use_ok $test->class, "use ok";
    `rm -rf /tmp/FileCache/myaggregator/`;
}

sub constructor : Tests(1) {
    my $test = shift;
    can_ok $test->class, 'new';
}

sub fetch_feed : Tests(5) {
    my $test = shift;
    can_ok $test->class, 'fetch_feed';

    ok my $obj = $test->class->new(), '... object is created';
    my $res = $obj->fetch_feed($test->url);
    is $res->code,      "200",          "... fetch is a success";
    like $res->content, qr/lumberjaph/, "... and content is good";

    # now data should be in cache
    my $ref = $obj->cache->get($test->url);
    ok defined $ref, "... url is now in cache";

    $res = $obj->fetch_feed($test->url);
    is $res->code, "304", "... already in cache";
}

sub feed_parser : Tests(3) {
    my $test = shift;
    can_ok $test->class, 'feed_parser';

    my $ua  = LWP::UserAgent->new;
    my $res = $ua->get($test->url);
    ok my $obj = $test->class->new(), "... object is created";
    my $feed = $obj->feed_parser(\$res->content);
    isa_ok $feed, "XML::Feed::Format::RSS";
}

1;
```

As you can see, some methods have an attribute, which indicate this method as a test method.

The startup method is run as the first method each time the tests are executed. In our case, we test if we can load our class, and we delete the cache of the aggregator.

We have a "constructor" test, that check we can do a new on our class.

Now we have to tests our 2 methods from the roles. We will test the fetch\_feed method first.

First, we indicate the number of tests that will be executed (6 in our case). Then we can write the test in the method:

-   create an object
-   fetch an url, and test the HTTP code of the response
-   check if the content look like something we want
-   now the data should be in cache, and the a new fetch of the url should return a 304 HTTP code

The second method to test is feed\_parser. This method will do 3 tests.

-   create an object
-   we manually fetch the content from a feed
-   send this content to feed\_parser
-   the result should return a XML::<Feed::Format>::RSS object

When you run the tests now `prove t/run.t`

the following result is produced:

``` bash
t/run.t ..
1..11
ok 1 - use Test::TestObject;
#
# Test::MyRoles->constructor
ok 2 - Test::TestObject->can('new')
#
# Test::MyRoles->feed_parser
ok 3 - Test::TestObject->can('feed_parser')
ok 4 - ... object is created
ok 5 - The object isa XML::Feed::Format::RSS
#
# Test::MyRoles->fetch_feed
ok 6 - Test::TestObject->can('fetch_feed')
ok 7 - ... object is created
ok 8 - ... fetch is a success
ok 9 - ... and content is good
ok 10 - ... url is now in cache
ok 11 - ... already in cache
ok
All tests successful.
Files=1, Tests=11,  3 wallclock secs ( 0.03 usr  0.01 sys +  0.66 cusr  0.09 csys =  0.79 CPU)
Result: PAS
```

### Aggregator

As we have our tests for the roles, we can write the tests for the aggregator now. First, we add a new line in **t/run.t**.

``` perl
    use Test::MyAggregator
```

We edit our **t/tests/Test/MyAggregator.pm**:

``` perl
    package Test::MyAggregator;

    use strict;
    use warnings;
    use base 'Test::Class';
    use Test::Exception;
    use Test::More;

    sub class {'MyAggregator'}

    sub context {
        {   dsn       => 'dbi:SQLite:dbname=/tmp/myaggregator.db',
            kioku_dir => 'dbi:SQLite:/tmp/mykioku.db',
        };
    }

    sub startup : Tests(startup => 2) {
        my $test = shift;
        use_ok $test->class, "use ok";
        `touch /tmp/myaggregator.db`;
        my $context = $test->context;
        my $dsn     = $context->{dsn};
        my $schema  = MyModel->connect($dsn);
        $schema->deploy;

        ok $schema->resultset('Feed')->create(
            {   feedid => 1,
                url    => 'http://lumberjaph.net/blog/index.php/feed/',
            }
            ),
            "... insert one feed in the db";
    }

    sub shutdown : Tests(shutdown => 2) {
        my $test = shift;
        ok unlink '/tmp/myaggregator.db', '... unlink db test';
        ok unlink '/tmp/mykioku.db',      '... unlink kioku test';
    }

    sub constructor : Tests(1) {
        my $test = shift;
        can_ok $test->class, 'new';
    }

    sub dedupe_feed : Tests(4) {
        my $test = shift;

        my $context = $test->context;
        my $ua      = LWP::UserAgent->new;
        my $res     = $ua->get("http://lumberjaph.net/blog/index.php/feed/");

        ok my $obj = $test->class->new(context => $context),
            "...  MyAggregator created";

        $obj->dedupe_feed($res, 1);

        my $schema = MyModel->connect($context->{dsn});
        is $schema->resultset('Entry')->search()->count, 10,
            '... 10 entries in the db';

        my $first = $schema->resultset('Entry')->search()->first;
        my $res_kiokudb;
        $obj->kioku->txn_do(
            scope => 1,
            body  => sub {
                $res_kiokudb = $obj->kioku->lookup($first->id);
            }
        );

        ok $res_kiokudb, '... got an object';
        is $res_kiokudb->permalink, $first->permalink, '... content is valid';
    }

    1;
```

The startup test create a database from our model, and insert a feed. The shutdown test remove the 2 database that we will use (MyModel and kiokudb).

The dedupe\_feed is really simple. We create a MyAggregator object, fetch a rss feed manually, and dedup the result. Now we check the result in the MyModel database: do we have 10 entries ? if it's the case, we are good. We fetch a result from this db, and check if it's also present in KiokuDB, and if the permalink is the same for the two. So with 4 tests, we do a simple check of our class.

Execute the tests (you can comment the roles' tests in run.t):

``` perl
    t/run.t ..
    1..9
    ok 1 - use MyAggregator;
    ok 2 - ... insert one feed in the db
    #
    # Test::MyAggregator->constructor
    ok 3 - MyAggregator->can('new')
    #
    # Test::MyAggregator->dedupe_feed
    ok 4 - ...  MyAggregator created
    ok 5 - ... 10 entries in the db
    ok 6 - ... got an object
    ok 7 - ... content is valid
    ok 8
    ok 9
    ok
    All tests successful.
    Files=1, Tests=9,  3 wallclock secs ( 0.01 usr  0.01 sys +  1.39 cusr  0.12 csys =  1.53 CPU)
    Result: PASS
```

We have our tests, so next step is the Catalyst frontend. As for the precedents parts, [the code is available on my git server](http://git.lumberjaph.net/p5-ironman-myaggregator.git/).
