Even though it's still a young project, an active community is starting to emerge around Dancer. Some modules start to appear on CPAN and github to add functionalities, or to extend existing ones.

Templates
---------

By default, Dancer comes with support for two templating systems: Template Toolkit and Dancer::Template::Simple, a small templating engine written by sukria. But support for other templating systems are available:

Dancer  
Template::Tenjin by ido

Dancer  
Template::Sandbox by Sam Graham

Dancer  
Template::Tiny by Sawyer

Dancer  
Template::MicroTemplate by me

Dancer  
Template::Mason by Yanick Champoux

Dancer  
Template::Haml by David Moreno

Logger
------

Out of the box, Dancer only has a simple logging system to write to file, but more logging sytems are available:

  <ul>

  <li>

Dancer::Logger::Syslog by sukria

  </li>

  <li>

Dancer::Logger::LogHandler by me

  </li>

  <li>

Dancer::Logger::PSGI by me

  </li>

  </ul>

The last one is for writing directly your log message via Plack. You can use a middleware like P::M::LogDispatch or P::M::Log4perl to handle logs for your application. Even better, if you use P::M::ConsoleLogger, you can have logs from your Dancer application in your javascript console.

Debug
-----

To debug your application with Plack, you can use the awesome Plack::Middleware::Debug. I've writen Dancer::Debug (which requires my fork of P::M::Debug), a middleware that add panels, with specific informations for Dancer applications.

To activate this middleware, update your app.psgi to make it look like this:

``` perl
    my $handler = sub {
        my $env     = shift;
        my $request = Dancer::Request->new($env);
        Dancer->dance($request);
    };
    $handler = builder {
        enable "Debug", panels => [
            qw/Dancer::Settings Dancer::Logger Environment Memory
                ModuleVersions Response Session Parameters Dancer::Version /
        ];
        $handler;
    };
```

Plugins
-------

Dancer has support for plugins since a few version. There is not a lot of plugins at the moment, but this will soon improve. Plugins support is one of the top priorities for the 1.2 release.

**\*** Dancer::Plugin::REST

This one is really nice. This plugin, used with the serialization stuff, allow you to write easily REST application.

``` perl
    resource user => get => sub {    # return user where id = params->{id} },
        create => sub {              # create a new user with params->{user} },
        delete => sub {          # delete user where id = params->{id} },
        update => sub {      # update user with params->{user} };
```

And you got the following routes:

-   GET *user*:id
-   GET *user*:id.:format
-   POST /user/create
-   POST /user/create.:format
-   DELETE *user*:id
-   DELETE *user*:id.:format
-   PUT *user*:id
-   PUT *user*:id.:format

\*\*\* Dancer::Plugin::Database

This plugin, by bigpresh, add the database keyword to your app.

``` perl
    use Dancer;
    use Dancer::Plugin::Database;

    # Calling the database keyword will get you a connected DBI handle:
    get '/widget/view/:id' => sub {
        my $sth = database->prepare('select * from widgets where id = ?',
            {}, params->{id});
        $sth->execute;
        template 'display_widget', {widget => $sth->fetchrow_hashref};
    };
```

**\*** Dancer::Plugin::SiteMap

With this plugin, by James Ronan, a sitemap of your application is created.

  <blockquote>

Plugin module for the Dancer web framwork that automagically adds sitemap routes to the webapp. Currently adds /sitemap and /sitemap.xml where the former is a basic HTML list and the latter is an XML document of URLS.

  </blockquote>

you can help! :)
----------------

There is still a lot of stuff to do. Don't hesitate to come on \#dancer@irc.perl.org to discuss ideas or new features that you would like.
