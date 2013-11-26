---
layout: post
summary: In which I talk about the shape of the CPAN
title: The shape of the CPAN
---

My talk at the [FPW](http://conferences.mongueurs.net/fpw2009/) this year is about the shape of the Perl and CPAN community. This talk was prepared by some [$coworkers](http://labs.rtgi.eu/) and me.

!/static/imgs/draft_cpan_prelimsmall.png(map of the Perl community on the web)!

We generated two maps (authors and modules) using the CPANTS' data. For the websites, we crawled a seed generated from the CPAN pages of the previous authors.

Each of this graphs are generated using a [force base algorithm](http://en.wikipedia.org/wiki/Force-based_algorithms), with the help of [Gephi](http://gephi.org/).

All the map are available in PDF files, in creative common licence. The slides are in french, but I will explain the three maps here.

 * [slides (french)](http://labs.rtgi.eu/fpw09/resources/slides/)
 * [authors map](http://labs.rtgi.eu/fpw09/resources/pdf/cpan_authors_core_march2009.pdf)
 * [modules map](http://labs.rtgi.eu/fpw09/resources/pdf/cpan_packages_core_march2009.pdf)
 * [community maps](http://labs.rtgi.eu/fpw09/resources/pdf/cpan-web-may2009-poster.pdf)
 * [community map (flash version)](http://labs.rtgi.eu/fpw09/map/)
 * [cpan-explorer.org](http://cpan-explorer.org/)

### CPAN's modules

The first map is about the modules available on the CPAN. We selected a list of modules which are listed as dependancies by at least 10 others modules, and the modules who used them. This graph is composed of 7193 nodes (or modules) and 17510 edges. Some clusters are interesting:

 * LWP and URI are really the center of the CPAN
 * a lot of web modules (XML::*, TemplateToolkit, HTML::Parser, ...)
 * TK is isolated from the CPAN
 * Moose, DBIx::Class and Catalyst are forming a group. This data are from march, we will try to do a newer version of this map this summer. This one will be really interesting as Catalyst have switched to Moose

### The CPAN's authors

This map is about the authors on the CPAN. There is about 700 authors and their connections. Each time an author use a module of another author, a link is created.

  * Modern Perl, constitued by Moose, Catalyst, DBIx::Class. Important authors are Steven, Sartak, perigin, jrockway, mstrout, nothingmuch, marcus ramberg
  * Slaven Rezi? and others TK developpers are on the border

### Web map

We crawled the web using the seed generated using the CPAN's authors pages.

 * again, the "modern group", on the top of the map, with Moose/Catalyst/DBIx::Class developpers
 * some enterprises, like shadowcat and iinteractive in the middle of the "modern Perl", Booking in the middle of the YAPC's websites (they are a major sponsor of this events), 6apart, ...
 * perl.org is the reference for the Perl community (the site is oriented on their sides)
 * cpan.org is the reference for the open source community
 * github is in the center of the Perl community. It's widely adopted by the Perl developpers. It offers all the "social media" features that are missing on the CPAN

I hope you like this visualisations, have fun analyzing them :)
