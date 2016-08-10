We have the model, the aggregator (and some tests), now we can do a basic frontend to read our feed. For this I will create a webapp using [Catalyst](http://www.catalystframework.org).

[Catalyst::Devel](http://search.cpan.org/perldoc?Catalyst::Devel) is required for developping catalyst application, so we will install it first:

``` perl
    % cpan Catalyst::Devel
```

Now we can create our catalyst application using the helper:

``` perl
    % catalyst.pl MyFeedReader
```

This command initialise the framework for our application **MyFeedReader**. A number of files are created, like the structure of the MVC directory, some tests, helpers, ...

We start by creating a view, using [TTSite](http://search.cpan.org/perldoc?Catalyst::View::TT). TTSite generate some templates for us, and the configuration for this template. We will also have a basic CSS, a header, footer, etc.

``` example
    cd MyFeedReader
    perl script/myfeedreader_create.pl view TT TTSite
```

TTSite files are under **root/src** and **root/lib**. A **MyAggregator/View/TT.pm** file is also created. We edit it to make it look like this:

``` perl
    __PACKAGE__->config({
        INCLUDE_PATH => [
            MyFeedReader->path_to( 'root', 'src' ),
            MyFeedReader->path_to( 'root', 'lib' )
        ],
        PRE_PROCESS  => 'config/main',
        WRAPPER      => 'site/wrapper',
        ERROR        => 'error.tt2',
        TIMER        => 0,
        TEMPLATE_EXTENSION => '.tt2',
    });
```

Now we create our first template, in **root/src/index.tt2**

``` example
    to <a href="/feed/">your feeds</a>
```

If you start the application (using `perl script/myfeedreader_server.pl`) and point your browser on <http://localhost:3000/>, this template will be rendered.

We need two models, one for KiokuDB and another one for MyModel:

**lib/MyFeedReader/Model/KiokuDB.pm**

``` perl
    package MyFeedReader::Model::KiokuDB;
    use Moose;
    BEGIN { extends qw(Catalyst::Model::KiokuDB) }
    1;
```

we edit the configuration file (**myfeedreader.conf**), and set the dsn for our kiokudb backend

``` example
        <Model KiokuDB>
            dsn dbi:SQLite:../MyAggregator/foo.db
        </Model>
```

**lib/MyFeedReader/Model/MyModel.pm**

``` perl
    package MyFeedReader::Model::MyModel;
    use base qw/Catalyst::Model::DBIC::Schema/;
    1;
```

and the configuration:

``` example
    <Model MyModel>
        connect_info dbi:SQLite:../MyModel/model.db
        schema_class MyModel
    </Model>
```

We got our view and our model, we can do the code for the controller. We need 2 controller, one for the feed, and one for the entries. The Feed controller will list them and display entries titles for a given feed. The Entry controller will just display them.

**lib/MyFeedReader/Controller/Feed.pm**

``` perl
    package MyFeedReader::Controller::Feed;
    use strict;
    use warnings;
    use parent 'Catalyst::Controller';

    __PACKAGE__->config->{namespace} = 'feed';

    sub index : Path : Args(0) {
        my ( $self, $c ) = @_;
        $c->stash->{feeds}
            = [ $c->model('MyModel')->resultset('Feed')->search() ];
    }

    sub view : Chained('/') : PathPart('feed/view') : Args(1) {
        my ( $self, $c, $id ) = @_;
        $c->stash->{feed}
            = $c->model('MyModel')->resultset('Feed')->find($id);
    }

    1;
```

The function `index` list the feeds, while the function `view` list the entries for a give feed. We use the chained action mechanism to dispatch this url, so we can have urls like this **/feed/\***

We create our 2 templates (for index and view):

**root/src/feed/index.tt2**

``` example
    <ul>
        [% FOREACH feed IN feeds %]
            <li><a href="/feed/view/[% feed.id %]">[% feed.url %]</a></li>
        [% END %]
    </ul>
```

**root/src/feed/vew.tt2**

``` example
    <h1>[% feed.url %]</h1>

    <h3>entries</h3>
    <ul>
        [% FOREACH entry IN feed.entries %]
            <li><a href="/entry/[% entry.id %]">[% entry.permalink %]</a></li>
        [% END %]
    </ul>
```

If you point your browser to <http://localhost:3000/feed/> you will see this:

Now the controller for displaying the entries:

``` perl
    package MyFeedReader::Controller::Entry;
    use strict;
    use warnings;
    use MyAggregator::Entry;
    use parent 'Catalyst::Controller';

    __PACKAGE__->config->{namespace} = 'entry';

    sub view : Chained('/') : PathPart('entry') : Args(1) {
        my ( $self, $c, $id ) = @_;
        $c->stash->{entry} = $c->model('KiokuDB')->lookup($id);
    }

    1;
```

The function **view** fetch an entry from the kiokudb backend, and store it in the stash, so we can use it in our template.

**root/src/entry/view.tt2**

``` example
    <h1><a href="[% entry.permalink %]">[% entry.title %]</a></h1>
    <span>Posted [% entry.date %] by [% entry.author %]</span>
    <div id="content">
        [% entry.content %]
    </div>
```

If you point your browser to an entry (something like \*<http://localhost:3000/entry/somesha256value*>), you will see an entry:

Et voila, we are done with a really basic feed reader. You can add methods to add or delete feed, mark an entry as read, ...

[The code is available on my git server](http://git.lumberjaph.net/p5-ironman-myfeedreader.git/).
