---
date: 2009-07-07T00:00:00Z
summary: In which I show how to auto answer questions asked by cpan
title: CPAN and auto-install
---

When you install a module from the [CPAN](http://search.cpan.org), and this module requires other modules, the cpan shell will ask you if you want to install them. When you are installing [Catalyst](http://www.catalystframework.org/), it may take a while, and you may not want to spend your afternoon in front of the prompt answering "yes" every 5 seconds.

The solution is to set the environment variable **PERL_MM_USE_DEFAULT**. Next time you want to install a big app: `PERL_MM_USE_DEFAULT=1 cpan Catalyst KiokuDB` and your done.
