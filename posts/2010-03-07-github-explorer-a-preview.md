> You may want to see the final version here: [GitHub Explorer](/github-explorer/).

For the last weeks, I've been working on the successor of [CPAN Explorer](http://cpan-explorer.org/). This time, I've decided to create some visualizations (probably 8) of the various communities using [GitHub](http://github.com/). I'm happy with the result, and will soon start to publish the maps (statics and interactives) with some analyses. I'm publishing two previews: the Perl community and the european developers. These are not final results. The colors, fonts, and layout may change. But the structure of the graphs will be the same. All the data was collected using the [GitHub API](http://developer.github.com/).

<a href='/imgs/4413528529_8d6b8dca1c_o.webp'><img src='/static/imgs/github-perl-preview.webp' alt='the Perl community on GitHub' /></a>

Each node on the graph represents a developer. When a developer "follows" another developer on GitHub, a link between them is created. The color on the Perl community map represent the countries of the developer. One of the most visible things on this graph is that the japanese community is tighly connected and shares very little contact with the foreign developers. miyagawa obviously acts as a glue between japanese and worldwide Perl hackers.

<a href='/imgs/4414287310_20094fe6bc_o.webp'><img src='/static/imgs/github-europe-preview.webp' alt='European developers on GitHub' /></a>

The second graph is a little bit more complex. It represents the European developers on GitHub. Here the colors represent the languages used by the developers. It appears that ruby is by far the most represented language on GitHub, as it dominates the whole map. Perl is the blue cluster at the bottom of the map, and the green snake is... Python.

Thanks to [bl0b](http://code.google.com/p/tinyaml/) for his suggestions :)
