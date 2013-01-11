---
layout: post
title: Carbon's manhole
category: devops
---
We're rolling out Graphite and statsd at [work](http://saymedia.com), and I've spend some time debugging our setup.  Most of the time, the only thing I need is ``tcpdump`` to verify that a host is sending correctly the various metrics.

But today, thanks to a [stupid reason](http://if.andonlyif.net/blog/2013/01/the-case-of-the-disappearing-metrics.html), I've learned about another way to debug [carbon](http://graphite.readthedocs.org/en/latest/carbon-daemons.html): the manhole.  The idea of the manhole is to give you a access to a REPL attached to the live process.  When my boss told me about it, I was at first surprised to see this in a Python application.  I've already been exposed to this kind of debugging thanks to Clojure, where it's not uncommon to connect a REPL to your live application (for example, Heroku [document how to connect to a remote live REPL in your application](https://devcenter.heroku.com/articles/debugging-clojure)).  When I first heard of that I was very skeptical (give access to a *live* environment, and let the developer mess with the process ?!).  But I've learned to love it and I feel naked when I'm working in an environment where this is not available.  So I was happy to jump and take a look at that feature.

Since it's not very well documented and I had a hard time finding some information, let me share here the basics.

First you'll need to configure Carbon's to allow the connection:

{% highlight ini %}
ENABLE_MANHOLE = True # by default it's set to False
MANHOLE_INTERFACE = 127.0.0.1
MANHOLE_PORT = 7222
MANHOLE_USER = admin
MANHOLE_PUBLIC_KEY = <your public SSH key, the string, not the path to the key>
{% endhighlight %}

Now you can restart carbon, and connect to the Python shell with ``ssh admin@127.0.0.1 -p7222``.  This manhole is useful to get an idea of the data structure your process is handling, or to get an idea of what's going on (is there a lot of keys being held in memory?  Is the queue size for one metric huge? etc).

From here, you can execute Python code to examine the data of the process:

{% highlight python %}
>>> from carbon.cache import MetricCache
>>> print MetricCache['PROD.apps.xxx.yyy.zzz]
[(1357861603.0, 93800.0), (1357861613.0, 98200.0), (1357861623.0, 91900.0)]
{% endhighlight %}

The [``MetricCache``](https://github.com/graphite-project/carbon/blob/master/lib/carbon/cache.py#L19) class is a Python dictionary where you can access your keys.  You can also list all the metrics with the size of their queue with ``MetricCache.counts()``.

Or even force the daemon to write to disk all the data points:

{% highlight python %}
>>> from carbon.writer import writeCachedDataPoints
>>> writeCachedDataPoints()
{% endhighlight %}

Before doing any of that, I would recommend to read the code of carbon.  It's pretty short and quiet straight forward, especially the code of the [writer](https://github.com/graphite-project/carbon/blob/master/lib/carbon/writer.py).

Of course, you have to know what you're doing when you're executing code from a REPL in a live environment.
