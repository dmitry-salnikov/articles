As I've already mentionned in a [previous post](/carbons-manhole/), at [$work](http://saymedia.com) we are currently deploying Graphite and the usual suspects.

Finding articles on how to install all these tools is easy, there's plenty of them.  But what's *really* hard to find, are stories on *how to use them*: what's collected, how, why, how do you organize your metrics, do you rewrite them, etc.

What I want with this post is to start a discussion about usages, patterns, and good practices.  I'm going to share how *we*, at SAY, are using them, and maybe this could be the start of a conversation.

## Graphite/collectd/statsd

We're using [statsd](https://github.com/etsy/statsd), [collectd](https://collectd.org) [Graphite](https://github.com/graphite-project) (and soon [Riemann](http://riemann.io) for alerting).

### Retention

Our default retention policy is: `10s:1h, 1m:7d, 15m:30d, 1h:2y`.  We don't believe that Graphite should be used for alerting: it's a tool for looking at history and trends.

360 points for the last hour is enough to refer to a graph when an incident occurs.  Most of the teams are releasing at least once a week, so 1 minute definition for a week is enough to compare trends between two releases.  Then we go to a month (2 sprints) and they 2 years.  We thought at first to keep only 15 months (1year + 1 quarter to compare), but since we have enough disk space, we decided to keep two years, however we might decide to change that in the future.

### System

We don't do anything fancy here.  `collectd` is running on each host, and then write to a central `collectd` server.

### Services

For shared services (Memcached, Varnish, Apache, etc), we talk to `statsd`.  We have a Perl script named `sigmoid`, with the following usage:

```sh
Usage: ./sigmoid [<options>] <metricname> <value>
 Exactly one of:
 --counter (value defaults to 1)
 --aggregate
 --gauge
 --event
 --raw

 Other options:
 --disable-multiplex (for statsd only)
 --appname
 --hostname (to log on behalf of another machine)
```

This script is used by other scripts who monitor logs, status of apps, etc.  This way it's very easy for a Perl, Python, Shell script to just call `sigmoid` via `system`, and then send the metric and the value to `statsd`.

For some other services we might need something more specific.  Let's take a look at Apache.  We have another Perl script for the **CustomLog** settings (`CustomLog "|/usr/local/bin/apache-statsd"`).  The script is doing the following things:

* compute the size of the HTTP request in bytes
* compute how long it took to return the response

Then, it will send the following lines to `statsd` (with $base being the vhost in our case):

* `$base.all.requests:1|c` increases the total of HTTP requests we're receiving
* `$base.all.bytes:$bytes|ms` send the size, in bytes, of that request
* `$base.all.time:$msec|ms` the time spend to get the response

Now we will send the same line two more times, with a different prefix: `$base.method.$request_method` *and* `$base.status.$status`.

### Applications

Here, developers decide what they want to collect, and send the metric to `statsd`.

### Events

And finally we have events.  Every time we push an application or a configuration, we create a new event.

## Proxying statsd

We want metrics to be well organized, in a clear hierarchy.  [Jason Dixon](https://github.com/obfuscurity) wrote in a [blog post](http://obfuscurity.com/2012/05/Organizing-Your-Graphite-Metrics) that *Misaligned paths are ok*.  I disagree.  We're collecting more than 100k metrics so far.  If things are not well organized, it will become quickly very difficult to find what you're looking for.

So, here's how we organize our metrics.  The first level is the environment (PROD, CI, DEV, ...).  Then we have *apps* and *hosts*.  For the *host* section, we group by cluster type (Hadoop cluster, Web servers for TypePad, etc), and then you have the actual host, with all the metrics collected.  For *apps*, we have four main categories: *aggregate*, *counters*, *events* and *gauges* (I'll come back on that later).

Earlier I said that apps where sending metrics to `statsd`, but that's not exactly true.  We (mostly) never write directly to statsd or Graphite.

On each host, we have a Perl script listening.  This proxy will rewrite all the incoming metrics by appending to the name the environment, the cluster and so on.  This way when someone want to send a key, he doesn't have to care convention or using the correct prefix.

Also, it will also multiplex the metric: we want the same key to end-up under *host* and under *app*.  Let's take an example here.  If you're writing a web service, you may want to send a metric for the total time taken by an endpoint (this will be an aggregate).  Our key will be something like: **\<application-name\>.\<endpoint-name\>.\<http-method\>.\<total-time\>**.  The proxy, based on the network address, will determine that it's environment is CI, and that it's an application.  But it also knows the name of the server, and the cluster.  So two keys will be created:

* **\<CI\>.\<apps\>.\<aggregate\>.\<application-name\>.\<endpoint-name\>.\<http-method>.<total-time\>**
* **\<CI\>.\<hosts\>.\<cluster-name\>.\<host-name\>.\<aggregate\>.\<application-name\>.\<endpoint-name\>.\<http-method\>.\<total-time\>**

This way we can find the metric aggregated by application, or if we think there's a problem in one machine, we can compare per host the same metric.

## Other problems with statsd and Graphite

I don't know if it's a problem with vocabulary, or our maths (I admit that my maths are not good, but I trust Abe and Hachi's maths), but you can't imagine how much time we spend debating around the words gauges, counters and aggregates.  What they mean, how they work, when to use them.  So here's my questions: are we missing something obvious?  do we over think it? or is it also confusing, and people are misusing them?

Let's take **gauge** as an example.  If you read [the documentation for gauges](https://github.com/etsy/statsd/blob/master/README.md#gauges), it seems very simple: you send a value, and it will be recorded.  Well, the thing is it will record only the last value send during the 10 seconds interval.  This work well when you have a cron job that will look at something every minute and report a metric to `statsd`, not if you're sending that 10 times a second (and yes, we will provide a patch for documentation soon).

Another one where we lost a good amount of time: if you're smallest retention is different from the interval used by statsd to flush the data, they will be graphed incorrectly (see this [comment](https://github.com/etsy/statsd/issues/32#issuecomment-1830985)).

The best "documentation" for `statsd`, so far, are the discussions in the [issues](https://github.com/etsy/statsd/issues).

We have some other complains about Graphite.  Even after reading the [rationals](http://graphite.wikidot.com/whisper#toc1) for Whisper, I'm not convinced it was a good idea to replace RRD with it.  We also discovered some issues with [Graphite's functions](http://if.andonlyif.net/blog/2013/01/graphites-derivative-function-lies.html).

## Meetup

We've a huge basement at work that can be used to host meetup.  There's already a few meetup in the San Francisco about "devops" stuff ([Metrics Meetup](http://www.meetup.com/San-Francisco-Metrics-Meetup/events/98875712/), [SF DevOps](http://www.meetup.com/San-Francisco-DevOps/), etc), but maybe there's room for another one with a different format.

What I would like, is a kind of forum, where a topic is picked, and people share their *experiences* (the bad, the good and the ugly), not how to configure or deploy something.  And there's a lot of topics where I've questions: deployment (this will be the topic of my next entry I think), monitoring, alerting, post-mortem, etc.  If you're interested, send me an email, or drop a comment on this post.
