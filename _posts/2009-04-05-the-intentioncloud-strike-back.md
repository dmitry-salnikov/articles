---
layout: post
title: the intentioncloud strike back
summary: In which once again I bring the intention cloud back.
---

I've decided to rewrite the intention cloud. Still with [Catalyst](http://dev.catalystframework.org/wiki/), but I've replaced prototype with [jquery](http://jquery.com) this time. I've end up with less code than the previous version. For the moment, only google is available, but I will add overture, and may be more engines.

There is still some bug to fix, some tests to add, and I will be able to restore the [intentioncloud.net](http://intentioncloud.net) domain.

It's really easy to plug a database to a catalyst application using [Catalyst::Model::DBIC::Schema](http://p3rl.org/Catalyst::Model::DBIC::Schema).  Via the helper, you can tell the model to use [DBIx::Class::Schema::Loader](http://p3rl.org/DBIx:/Class::Schema::Loader), so the table informations will be loaded from the database at runtime. You end up with a code that looks like 

{% highlight perl %}
package intentioncloud::Model::DB;
use strict;
use base 'Catalyst::Model::DBIC::Schema';
__PACKAGE__->config(schema_class => 'intentioncloud::Schema',);
1;
{% endhighlight %}

and the schema:

{% highlight perl %}
package intentioncloud::Schema;
use strict;
use base qw/DBIx::Class::Schema::Loader/;
__PACKAGE__->loader_options(relationships => 1);
1;
{% endhighlight %}

Now, to do a query:

{% highlight perl %}
my $rs = $c->model('DB::TableName')->find(1);
{% endhighlight %}

and your done !

The code for the intentioncloud is avaible on [GitHub](http://github.com/franckcuny/intentioncloud/tree/master).


