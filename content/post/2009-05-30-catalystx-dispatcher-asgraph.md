---
date: 2009-05-30T00:00:00Z
summary: In which I wrote a module to visualize routes in Catalyst.
title: CatalystX::Dispatcher::AsGraph
---

This morning I saw [this post](http://marcus.nordaaker.com/awesome-route-graph-with-mojoxroutesasgraph/) from Marcus Ramberg about [MojoX::Routes::AsGraph](http://search.cpan.org/perldoc?MojoX::Routes::AsGraph). I liked the idea. But as I Catalyst instead of Mojo, I thought I could give a try and do the same thing for Catalyst dispatcher, and I've coded CatalystX::Dispatcher::AsGraph. For the moment only private actions are graphed.

<img src='/imgs/routes-300x249.webp' alt='routes'>

You use it like this: `perl bin/catalyst_graph_dispatcher.pl --appname Arkham --output routes.png`

You can create a simple script to output as text if you prefer:

```perl
#!/usr/bin/perl -w
use strict;
use CatalystX::Dispatcher::AsGraph;

my $graph = CatalystX::Dispatcher::AsGraph->new_with_options();
$graph->run;
print $graph->graph->as_txt;
```

The code is on [my git server](http://git.lumberjaph.net/p5-catalystx-dispatcher-asgraph.git/) for the moment.

For thoses who are interested by visualization, I'll publish soon some (at least I think) really nice visualisations about CPAN, Perl, and his community, that we have created at [$work](http://rtgi.fr).
