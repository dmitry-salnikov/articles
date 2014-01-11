---
layout: post
title: debug your DBIx::Class queries
summary: In which I explain how to see SQL queries generated for DBIx::Class.
type: codex
---

If you use DBIx::Class and want to see what the SQL generated looks like, you can set the environment variable **DBIC_TRACE**.

{% highlight sh %}
% DBIC_TRACE=1 my_programme.pl
{% endhighlight %}

And all the SQL will be printed on **STDERR**.

If you give a filename to the variable, like this

{% highlight sh %}
% DBIC_TRACE="1=/tmp/sql.debug"
{% endhighlight %}

all the statements will be printed in this file.
