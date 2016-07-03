---
date: 2012-11-28T00:00:00Z
title: Perl, Redis and AnyEvent at Craiglist
---

Last night I went to the
[SF.pm](http://www.meetup.com/San-Francisco-Perl-Mongers/) meetup,
hosted by Craiglist (thanks for the food!), where
[Jeremy Zawodny](https://twitter.com/jzawodn) talked about
[Redis](http://redis.io) and his module
[AnyEvent::Redis::Federated](https://metacpan.org/module/AnyEvent::Redis::Federated).
We were about 30 mongers.

I was eating at the same table as Craiglist CTO's, and he went through
some details of their infrastructure.  I was surprised by the quantity
of place where they use Perl, and the amount of traffic they deal with.

## Redis

Jeremey started his talk by explaining what is their current problem:
they have hundred of hosts in multiple data center, and they collect
continuously dozen of metrics.  They looked at MySQL to store them,
but it was too slow to support the writes.  Another thing
important for them is that mostly only the most recent data matters.  They
want to know what's going on *now*, they don't really care about the
past.

So their goal is simple: they need something fast, *really* fast, and
simple.  That's where Redis enter the game.

They want data replication, but
Redis don't have this feature: there's only a master/slave replication
mechanism (so, one way), and they need a solution with multi master,
where a node becoming master does not drop data. They address this
issue with a "syncer", that I'll describe later.

Because Redis is single thread, and servers have multiple cores, they
start 8 process on each node to take advantages of them.

To me, the main benefit of Redis over Memcached is that you can use
it as a data structure server.  If you only need something to store
key value, I'll prefer to stick to memcached: the community around is
bigger, there's a lot of well know patterns, and a lot of big
companies are contributing to it (lately, Twitter and FaceBook).

The structure they use the most are the
[*sorted set*](http://redis.io/commands#sorted_set).  The format to store a metric is:

 *  key: `$time_period:$host:$metric` (where the $timeperiod is
    usually a day)
 *  score: `$timestamp`
 *  value: `$timestamp:$value`

In addition of storing those metrics in the nodes, they also keep a
journal of what has changed.  The journal looks like this:

 *  score: `$timestamp` of the last time something has changed
 *  value: `$key` that changed
  
The journal is only one big structure, and it's used by their syncer
(more about that in a moment).  The benefit of having ZSET is that
they can delete old data easily by using the key (they don't have
enough memory to store more than a couple of days, so they need to be
able to delete by day kickly).

The journal is use for replication.  Each process has a syncer that
track all his peers, pull the data from those nodes and merge them
with the local data.  Earlier Jeremy mentioned that they have 8
instances on each node, so a the syncer from process 1 on node a will
only check for the process 1 on node b.

He also mentioned a memory optimization done by Redis (you can read
more about that [here](http://redis.io/topics/memory-optimization)).

## AnyEvent::Redis::Federated

Now, it's time to see the Perl code. `AnyEventE::Redis::Federated` is
a layer on top of `AnyEvent::Redis` that implements a consistent
hashing.  I guess now every body has gave up hope to see someday
[redis cluster](http://redis.io/topics/cluster-spec) (and I'm more and
more convinced that hit should never be implemented, and let the
client implement their own solution for hashing / replication).

Some of the nice feature of the modules:

 *  call chaining
 *  [you can get singleton object for the connection](https://metacpan.org/module/AnyEvent::Redis::Federated#SHARED-CONNECTIONS)
 *  you can also use it in blocking mode
 *  query all node (where you send the same command to all the node,
   can be useful to do sanity check on the data)
 *  the client will write to one node, and let the syncer do the job

He then showed us some code (with a very gross example: `new
AnyEvent::Redis::Federated`, I know at least
[one person](http://search.cpan.org/perldoc?indirect) who would have
probably said something :).

## Concerns

The idea seems fine, but, as one person noted during the Q&A, how will
this scale when you have more than 2 or 4 nodes in your cluster ?
Since each process' syncer need to talk to *all* the other nodes, it
will probably be very expensive for this process to gather information
from all the nodes and write them.  Also, by adding more nodes, you're
storing less information into each process, since you replicate
everything.  Maybe a good solution is to keep many small cluster of
2 to 4 nodes, and let each of them deal with some specific metrics.

The module is not yet used in production, but they've tested it
heavily, in a lot of conditions (but I would note that there's no unit
test :).  They intent to use it soon with some
home made dashboard to display the metrics.

