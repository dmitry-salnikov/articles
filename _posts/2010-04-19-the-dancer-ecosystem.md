---
layout: post
summary: In which we look at Dancer's ecosystem.
title: The Dancer Ecosystem
---

Even though it's still a young project, an active community is starting to emerge around <a href="http://search.cpan.org/perldoc?Dancer">Dancer</a>. Some modules start to appear on CPAN and github to add functionalities, or to extend existing ones.

## Templates

By default, Dancer comes with support for two templating systems: <a href="http://search.cpan.org/dist/Template-Toolkit/">Template Toolkit</a> and Dancer::Template::Simple, a small templating engine written by <a href="http://www.sukria.net/">sukria</a>. But support for other templating systems are available:


 * <a href="http://search.cpan.org/perldoc?Dancer::Template::Tenjin">Dancer::Template::Tenjin</a> by ido
 * <a href="http://search.cpan.org/perldoc?Dancer::Template::Sandbox">Dancer::Template::Sandbox</a> by Sam Graham
 * <a href="http://search.cpan.org/perldoc?Dancer::Template::Tiny">Dancer::Template::Tiny</a> by Sawyer
 * <a href="http://search.cpan.org/perldoc?Dancer::Template::MicroTemplate">Dancer::Template::MicroTemplate</a> by me
 * <a href="http://search.cpan.org/perldoc?Dancer::Template::Mason">Dancer::Template::Mason</a> by Yanick Champoux
 * <a href="http://search.cpan.org/perldoc?Dancer::Template::Haml">Dancer::Template::Haml</a> by David Moreno

## Logger

Out of the box, Dancer only has a simple logging system to write to file, but more logging sytems are available:

<ul>
<li><a href="http://search.cpan.org/perldoc?Dancer::Logger::Syslog">Dancer::Logger::Syslog</a> by sukria</li>
<li><a href="http://search.cpan.org/perldoc?Dancer::Logger::LogHandler">Dancer::Logger::LogHandler</a> by me</li>
<li><a href="http://git.lumberjaph.net/p5-dancer-logger-psgi.git/">Dancer::Logger::PSGI</a> by me</li>
</ul>

The last one is for writing directly your log message via <ah href="http://search.cpan.org/perldoc?Plack">Plack</a>. You can use a middleware like <a href="http://search.cpan.org/~miyagawa/Plack-0.9932/lib/Plack/Middleware/LogDispatch.pm">P::M::LogDispatch</a> or <a href="http://search.cpan.org/~miyagawa/Plack-0.9932/lib/Plack/Middleware/Log4perl.pm">P::M::Log4perl</a> to handle logs for your application. Even better, if you use <a href="http://github.com/miyagawa/Plack-Middleware-ConsoleLogger">P::M::ConsoleLogger</a>, you can have logs from your Dancer application in your javascript console.

## Debug

To debug your application with Plack, you can use the awesome <a href="http://search.cpan.org/perldoc?Plack::Middleware::Debug">Plack::Middleware::Debug</a>. I've writen <a href="http://git.lumberjaph.net/p5-dancer-debug.git/">Dancer::Debug</a> (which requires my fork of <a href="http://github.com/franckcuny/Plack-Middleware-Debug">P::M::Debug</a>), a middleware that add panels, with specific informations for Dancer applications.

<img src="/static/imgs/4535496880_37e5e68a57_z.webp" alt="Dancer::Debug middleware" />

To activate this middleware, update your app.psgi to make it look like this:

{% highlight perl %}
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
{% endhighlight %}

## Plugins

Dancer has support for plugins since a few version. There is not a lot of plugins at the moment, but this will soon improve. Plugins support is one of the top priorities for the 1.2 release.

### Dancer::Plugin::REST

<a href="http://github.com/sukria/Dancer-Plugin-REST">This one is really nice</a>. This plugin, used with the serialization stuff, allow you to write easily REST application.

{% highlight perl %}
resource user => get => sub {    # return user where id = params->{id} },
    create => sub {              # create a new user with params->{user} },
    delete => sub {          # delete user where id = params->{id} },
    update => sub {      # update user with params->{user} };
{% endhighlight %}

And you got the following routes:

 * GET /user/:id
 * GET /user/:id.:format
 * POST /user/create
 * POST /user/create.:format
 * DELETE /user/:id
 * DELETE /user/:id.:format
 * PUT /user/:id
 * PUT /user/:id.:format

### Dancer::Plugin::Database

<a href="http://github.com/bigpresh/Dancer-Plugin-Database">This plugin</a>, by bigpresh, add the <strong>database</strong> keyword to your app.

{% highlight perl %}
use Dancer;
use Dancer::Plugin::Database;

# Calling the database keyword will get you a connected DBI handle:
get '/widget/view/:id' => sub {
    my $sth = database->prepare('select * from widgets where id = ?',
        {}, params->{id});
    $sth->execute;
    template 'display_widget', {widget => $sth->fetchrow_hashref};
};
{% endhighlight %}

### Dancer::Plugin::SiteMap

<a href="http://search.cpan.org/perldoc?Dancer::Plugin::SiteMap">With this plugin</a>, by James Ronan, a <a href="http://en.wikipedia.org/wiki/Sitemap">sitemap</a> of your application is created.

<blockquote>Plugin module for the Dancer web framwork that automagically adds sitemap routes to the webapp. Currently adds /sitemap and /sitemap.xml where the former is a basic HTML list and the latter is an XML document of URLS.</blockquote>

## you can help! :)

There is still a lot of stuff to do. Don't hesitate to come on #dancer@irc.perl.org to discuss ideas or new features that you would like.
