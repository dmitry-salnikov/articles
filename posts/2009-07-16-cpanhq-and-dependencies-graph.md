CPANHQ is a new project that "aims to be a community-driven, meta-data-enhanced alternative to such sites as [search.cpan.org](http://search.cpan.org) and [kobesearch.cpan.org](http://kobesearch.cpan.org/).

I believe that a good vizualisation can help to have a better understanding of datas. One of the missing thing on the actual search.cpan.org is the lack of informations about a distribution's dependencies. So my first contribution to the CPANHQ project was to add such informations.

&lt;img src='/imgs/cpanhq-dep.webp' alt='cpanhq deps' align=left'&gt;

For each distributions, a graph is generated for the this distribution. For this, I use [Graph::Easy](http://search.cpan.org/perldoc?Graph::Easy) and data available from the CPANHQ database. I alsa include a simple list of the dependencies after the graph.

Only the first level dependencies are displayed, as the distribution's metadata are analysed when the request is made. I could follow all the dependencies when the request is made, but for some distribution it could take a really long time, and it's not suitable for this kind of services.

**edit**: you can find [CPANHQ on GitHub](http://github.com/bricas/cpanhq/tree/master).
