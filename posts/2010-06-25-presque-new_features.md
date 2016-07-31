I've added a few new features to [presque](http://github.com/franckcuny/presque).

[presque](/presque-a-redis-tatsumaki-based-message-queue/) is a persistant job queue based on [Redis](http://github.com/antirez/redis) and [Tatsumaki](http://github.com/miyagawa/Tatsumaki).

A short list of current features implemented:

* jobs are JSON object
* possibility to stop/start queues
* jobs can be delayed to run after a certain date in the future
* workers can register themself, doing this, you can know when a worker started, what he have done, ...
* statistics about queue, jobs, and workers
* possible to store and fetch jobs in batch
* a job can be unique

The REST interface is simple, and there is only a few methods. It's fast (I will provide numbers soon from our production environment), and workers can be implemented in any languages.

There have been a lot of refactoring lately. The main features missing right now are a simple HTML interface that will display various informations, pulling the data from the REST API (hint : if someone want to help to design this one ... :) ), websocket (sending a message to all workers).

There is a Perl client to the REST API: [net::presque](http://git.lumberjaph.net/p5-net-presque.git/), that you can use with [net::http::console](http://git.lumberjaph.net/p5-net-http-console.git/):

```bash
% perl bin/http-console --api_lib Net::Presque --url http://localhost:5000
http://localhost:5000> fetch_job {"queue_name":"twitter_stream"}
{
    "text" : "Australias new prime minister - julia gillard is our 27th prime minister.",
    "user" : "Lov3LifeAlways"
}
```

I've also wrote a better [worker for Perl](http://git.lumberjaph.net/p5-presque-worker.git/). It's a Moose::Role that you apply to your class. You need to write a **work** method, and your done. This worker handle retries, provide a logger, ... As for [resque](http://github.com/defunkt/resque), there is two dispatcher:

* normal : the worker grab a job, process it, then ask for the next job
* fork : the worker grab a job, fork, let the child do the job and exit, while the parent ask for the next job. As resque says, "Resque assumes chaos". And me too, I like (ordered) chaos

I hope to finish the documentation and to writes one or two more workers as example (maybe in Python and javascript/node.js) soon to be able to tag a first version, and to collect some info about how many jobs have been processed at work (we use it to do url resolution and collect twitter data among few other things). Although I'm not sure I will release it to CPAN.
