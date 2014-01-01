---
title: A simple feed aggregator with modern Perl - part 1
summary: In which I write a feed aggregator in Perl.
layout: post
---

Following [Matt's post](http://www.shadowcat.co.uk/blog/matt-s-trout/iron-man/) about people not blogging enough about Perl, I've decided to try to post once a week about Perl. So I will start by a series of articles about what we call **modern Perl**. For this, I will write a simple feed agregator (using [Moose](https://metacpan.org/pod/Moose), [DBIx::Class](http://search.cpan.org/perldoc?DBIx::Class), [KiokuDB](http://search.cpan.org/perldoc?KiokuDB), some tests, and a basic frontend (with [Catalyst](http://search.cpan.org/perldoc?Catalyst)). This article will be split in four parts:

 * the first one will explain how to create a schema using **DBIx::Class**
 * the second will be about the aggregator. I will use **Moose*** and **KiokuDB**
 * the third one will be about writing tests with **Test::Class**
 * the last one will focus on **Catalyst**

The code of these modules will be available on [my git server](http://git.lumberjaph.net/) at the same time each article is published.

> I'm not showing you how to write the perfect feed aggregator.  The purpose of this series of articles is only to show you how to write a simple aggregator using modern Perl.

### The database schema

We will use a database to store a list of feeds and feed entries. As I don't like, no, wait, I *hate* SQL, I will use an ORM for accessing the database. For this, my choice is **DBIx::Class**, the best ORM available in Perl.

> If you never have used an ORM before, ORM stands for Object Relational Mapping. It's a SQL to OO mapper that creates an abstract encapsulation of your databases operations. **DBIx::Class**' purpose is to represent "queries in your code as perl-ish as possible.

For a basic aggregator we need:

 * a table for the list of feeds
 * a table for the entries

We will create these two tables using *DBIx::Class*. For this, we first create a Schema module. I use *Module::Setup*, but you can use **Module::Starter** or whatever you want.

{% highlight bash %}
% module-setup MyModel
% cd MyModel
% vim lib/MyModel.pm
{% endhighlight %}

{% highlight perl %}
package MyModel;
use base qw/DBIx::Class::Schema/;
__PACKAGE__->load_classes();
1;
{% endhighlight %}

So, we have just created a schema class. The **load_classes** method loads all the classes that reside under the **MyModel** namespace. We now create the result class **MyModel::Feed** in **lib/MyModel/Feed.pm**:

{% highlight perl %}
package MyModel::Feed;
use base qw/DBIx::Class/;
__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('feed');
__PACKAGE__->add_columns(qw/ feedid url /);
__PACKAGE__->set_primary_key('feedid');
__PACKAGE__->has_many(entries => 'MyModel::Entry', 'feedid');
1;
{% endhighlight %}

Pretty self explanatory: we declare a result class that uses the table feed, with two columns: **feedid** and **url**, **feedid** being the primary key. The **has_many** method declares a one-to-many relationship.

Now the result class **MyModel::Entry** in **lib/MyModel/Entry.pm**:

{% highlight perl %}
package MyModel::Entry;
use base qw/DBIx::Class/;
__PACKAGE__->load_components(qw/Core/);
__PACKAGE__->table('entry');
__PACKAGE__->add_columns(qw/ entryid permalink feedid/);
__PACKAGE__->set_primary_key('entryid');
__PACKAGE__->belongs_to(feed => 'MyModel::Feed', 'feedid');
1;
{% endhighlight %}

Here we declare **feed** as a foreign key, using the column name **feedid**.

You can do a more complex declaration of your schema. Let's say you want to declare the type of your fields, you can do this:

{% highlight perl %}
__PACKAGE__->add_columns(
    'permalink' => {
        'data_type'         => 'TEXT',
        'is_auto_increment' => 0,
        'default_value'     => undef,
        'is_foreign_key'    => 0,
        'name'              => 'url',
        'is_nullable'       => 1,
        'size'              => '65535'
    },
);
{% endhighlight %}

**DBIx::Class** also provides hooks for the deploy command. If you are using MySQL, you may need a InnoDB table. In your class, you can add this:

{% highlight perl %}
sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;
    $sqlt_table->extra(
        mysql_table_type => 'InnoDB',
        mysql_charset    => 'utf8'
    );
}
{% endhighlight %}

Next time you call deploy on this table, the hook will be sent to **SQL::Translator::Schema**, and force the type of your table to InnoDB, and the charset to utf8.

Now that we have a **DBIx::Class** schema, we need to deploy it. For this, I always do the same thing: create a **bin/deploy_mymodel.pl** script with the following code:

{% highlight perl %}
use strict;
use feature 'say';
use Getopt::Long;
use lib('lib');
use MyModel;

GetOptions(
    'dsn=s'    => \my $dsn,
    'user=s'   => \my $user,
    'passwd=s' => \my $passwd
) or die usage();

my $schema = MyModel->connect($dsn, $user, $passwd);
say 'deploying schema ...';
$schema->deploy;

say 'done';

sub usage {
    say
        'usage: deploy_mymodel.pl --dsn $dsn --user $user --passwd $passwd';
}
{% endhighlight %}

This script will deploy for you the schema (you need to create the database first if using with mysql).

Executing the following command `perl bin/deploy_mymodel.pl --dsn dbi:SQLite:model.db` will generate a **model.db** database so we can work and test it. Now that we got our (really) simple **MyModel** schema, we can start to hack on our aggregator.

[The code is available on my git server](http://git.lumberjaph.net/p5-ironman-mymodel.git/).

> while using **DBIx::Class**, you may want to take a look at the generated queries. For this, export `DBIC_TRACE=1` in your environment, and the queries will be printed on STDERR.
