The site [cpan-explorer](http://cpan-explorer.org/) have been update with three new maps for the [YAPC::EU](http://yapceurope2009.org/ye2009/). This three maps are different from the previous one. This time, instead of having a big photography of the distributions and authors on the CPAN, Task::Kensho have been used to obtain a representation of what we call the **modern Perl**.

## distributions map

<img src='/imgs/moosedist.webp' alt='moose'>

Task::Kensho acted as the seed for this map. Task::Kensho contains a list of modules recommended to do modern Perl development. So we extracted the modules that have a dependancie toward one of these modules, and create the graph with this data.

## authors map

The authors listed on this map are the one from the previous map. There is a far less authors thant the previous authors map, but it's more readable. A lot of informations are on the map : label size, node size, edge size, color of the node.

## web communities map

This map look a lot like the previous one, as we used nearly the same data. The seed have been extended with a few websites only.

## cpan-explorer

CPAN Explorer is now hosted on a wordpress, so you can leave comments or suggestions for new maps you would like to see (a focus on web development modules, tests::* module, etc ...). All the new maps are also searchable, and give you a permalink for you search ([I'm here](http://cpan-explorer.org/2009/07/28/new-web-communities-map-for-yapceu/#dist%3Dlumberjaph.net) and [here](http://cpan-explorer.org/2009/07/28/version-of-the-authors-graph-for-yapceu/#author%3Dfranck))

I will give a talk at the [YAPC::EU](http://yapceurope2009.org/ye2009/talk/2061) about this work. Also, each map have been printed, and will be given for the auction.

This work is a collective effort from all the guys at [RTGI](http://rtgi.fr/) (antonin created the template for wordpress, niko the js and the tools to extract information from the SVG for the searchable map, julian helped me to create the graphs and extract valuable informations, and I got a lot of feedback from others coworkers), thanks guys!.
