> *More informations about the poster are available on [this post](http://lumberjaph.net/graph/2010/04/02/github-poster.html)*

Last year, with help from my coworkers at [Linkfluence](http://linkfluence.net/), I created two sets of maps of the [Perl](http://perl.org) and [CPAN](http://search.cpan.org/)'s community. For this, I collected data from CPAN to create three maps:

-   [dependencies between distributions](http://cpan-explorer.org/2009/07/28/new-version-of-the-distributions-map-for-yapceu/)
-   [which authors wre important in term of reliability](http://cpan-explorer.org/2009/07/28/version-of-the-authors-graph-for-yapceu/)
-   [and how the websites theses authors are structured](http://cpan-explorer.org/2009/07/28/new-web-communities-map-for-yapceu/)

I wanted to do something similar again, but not with the same data. So I took a look at what could be a good subject. One of the things that we saw from the map of the websites is the importance [GitHub](http://github.com/) is gaining inside the Perl community. GitHub provides a [really good API](http://develop.github.com/), so I started to play with it.

> This graph will be printed on a poster, size will be [A2](http://en.wikipedia.org/wiki/A2_paper_size) and [A1](http://en.wikipedia.org/wiki/A1_paper_size). Please, contact me franck.cuny \[at\] linkfluence.net if you will be interested by one.

This time, I didn't aim for the Perl community only, but the whole github communities. I've created several graphs:

> all the graph are available "on my flickr account":[http://www.flickr.com/photos/franck\\\_/sets/72157623447857405/](http://www.flickr.com/photos/franck\_/sets/72157623447857405/)

-   [a graph of all languages](http://www.flickr.com/photos/franck_/4460144638/)
-   [a graph of the Perl community](http://www.flickr.com/photos/franck_/4456072255/in/set-72157623447857405/)
-   [a graph of the Ruby community](http://www.flickr.com/photos/franck_/4456914448/)
-   [a graph of the Python community](http://www.flickr.com/photos/franck_/4456118597/in/set-72157623447857405/)
-   [a graph of the PHP community](http://www.flickr.com/photos/franck_/4456830956/in/set-72157623447857405/)
-   [a graph of the European community](http://www.flickr.com/photos/franck_/4456862434/in/set-72157623447857405/)
-   [a graph of the Japan community](http://www.flickr.com/photos/franck_/4456129655/in/set-72157623447857405/)

I think a disclaimer is important at this point. I know that github doesn't represent the whole open source community. With these maps, I don't claim to represent what the open source world looks like right now. This is not a troll about which language is best, or used at large. It's **ONLY** about GitHub.

Also, I won't provide deep analysis for each of these graphs, as I lack insight about some of those communities. So feel free to [re-use the graphs](http://franck.lumberjaph.net/graphs.tgz) and provide your own analyses.

Methodology
-----------

I didn't collect all the profiles. We (with [Guilhem](http://twitter.com/gfouetil) decided to limit to peoples who are followed by at least two other people. We did the same thing for repositories, limiting to repositories which are at least forked once. Using this technique, more than 17k profiles have been collected, and nearly as many repositories.

For each profile, using the github API, I've tried to determine what the main language for this person is. And with the help of the [geonames](http://www.geonames.org), find the right country to attach the profile to.

Each profile is represented by a node. For each node, the following attributes are set:

-   name of the profile
-   main language used by this profile, determined by github
-   name of the country
-   follower count
-   following count
-   repository count

An edge is a link between two profiles. Each time someone follows another profile, a link is created. By default, the weight of this link is 1. For each project this person forked from the target profile, the weight is incremented.

As always, I've used [Gephi](http://gephi.org/) (now in version 0.7) to create the graphs. Feel free to download the various graph files and use them with Gephi.

Github
------

> properties of the graph: 16443 nodes / 130650 edges

The first map is about all the languages available on github. This one was really heavy, with more than 17k nodes, and 130k edges. The final version of the graph use the 2270 more connected nodes.

You can't miss Ruby on this map. As github uses Ruby on Rails, it's not really surprising that the Ruby community has a particular interest on this website. The main languages on github are what we can expect, with PHP, Python, Perl, Javascript.

Some languages are not really well represented. We can assume that most Haskell projects might use darcs, and therefore are not on github. Some other languages may use other platforms, like launchpad, or sourceforge.

Perl
----

> properties of the graph: 365 nodes / 4440 edges

The Perl community is split into two parts. On the left side, there is the occidental community, driven by people like "Florian":<http://github.com/rafl>, "Yuval":<http://github.com/nothingmuch>, "rjbs":<http://github.com/rjbs>, ... The second part are the japanese Perl hackers, with Tokhuirom, Typester, Yappo, ... And in between them, Miyagawa acts as a glue. This map looks a lot like the previous map of the CPAN. We can see that this community is international, with the exception of Japan that don't mix with others.

There is no main project on github that gathers people, even though we can see a fair amount of MooseX:: projects. Most of the developers will work on different modules, that may not have the same purpose. Lately we have seen a fair amount of work on various Plack stuff, mainly middleware, but also HTTP servers (twiggy, starman, ...) and web framework (dancer).

One important project that is not (deliberately) represented on this graph is the gitpan, Schwern's project. The gitpan is an import of all the CPAN modules, with complete history using the Backpan.

To conclude about Perl, there are only 365 nodes on this graph, but no less than 4440 edges. That's nearly two times the number of edges compared to the Python community. Perl is a really well structured community, probably thanks to the CPAN, which already acted as hub for contributors.

Python
------

> properties of the graph: 532 nodes / 2566 edges

The Python community looks a lot like the Perl community, but only in the structure of the graph. If we look closely, Django is the main project that represent Python on Github, in contrast with Perl where there is no leader. Some small projects gather small community of developers.

PHP
---

> properties of the graph: 301 nodes / 1071 edges

PHP is the only community that is structured this way on Github. We can clearly see that people are structured based on a project where they mainly contribute.

CakePHP and Symphony are the two main projects. Nearly all the projects gather an international community, at the exception of a few japanese-only projects

Ruby
----

> properties of the graph: 3742 nodes / 24571 edges

As for the Github graph, we can clearly see that some countries are isolated. On the right side, we have: the Japan community is at the bottom; the Spanish at the top. Australian are represented on the upper right corner, while on the left side we got the Brazilians.

The main projects that gather most of the hackers are Rails and Sinatra, two famous web frameworks.

Europe
------

> properties of the graph: 2711 nodes / 11259 edges

This one shows interesting features. Some countries are really isolated. If we look at Spain, we can see a community of Ruby programmers, with an important connectivity between them, but no really strong connection with any foreign developers. We can clearly see the Perl community exists as only one community, and is not split by country. The same is true for Python.

Japanese hackers community
--------------------------

> properties of the graph: 559 nodes / 5276 edges

This community is unique on github. In 2007, Yappo created coderepos.org, a repository for open source developers in Japan. It was a subversion repository, with Trac as an HTTP front-end. It gathered around 900 developers, with all kind of projects (Perl, Python, Ruby, Javascript, ...). Most of these users have switched to github now.

Three main communities are visible on this graph: Perl; Ruby; PHP. As always, the Javascript community as a glue between them. And yes, we can confirm that Perl is big in Japan.

We have seen in the previous graph that the Japanese hackers are always isolated. We can assume that their language is an obstacle.

This is a really well-connected graph too.

Conclusions and graphs
----------------------

I may have not provided a deep analysis of all the graph. I don't have knowledge of most of the community outside of Perl. Feel free to download the graph, to load them in Gephi, experiment, and provides your own thoughts.

I would like to thanks everybody at Linkfluence (guilhem for his advices, camille for giving me time to work on this, and antonin for the amazing poster), who have helped me and let me use time and resources to finish this work. Special thanks to blob for reviewing my prose and cdlm for the discussion :)
