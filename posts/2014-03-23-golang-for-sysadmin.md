Recently I've been reading articles about golang and how it can be used to replace scripts that you would usually write in Python Perl or Bash. I can understand why you would do that (you get a binary, so it's faster, it works without the need of an interpreter, etc).

At work we have a "ops.git" repository with all our rules for cfengines, configurations for services, zones for DNS, and also a tons of scripts. Most of them, today, are in Python/Perl/Bash. I've been looking and toying to replace some of them with golang, but I don't see how we could do that without modifying the existing setup.

This scripts are copied on a system by `cfengine`, usually in `/usr/local/bin`. I'm trying to figure out how would you do that for programs in go ? I can't imagine a solution where you would have to compile the binary and commit it to the repository (the size of the repository would just explode), and I don't like the idea of having a hook in `cfengine` to compile and put them in place.

The main solution that I can see here is to have a different repository with all the scripts, and let jenkins build a debian package (something like $company-ops-tools.deb) and then have it deployed/upgraded by cfengine via `apt`.

Another solution would have to put a Makefile into this repository and let jenkins build some artifacts, put them in a package, and get it deployed.

Is there another simpler solution ? By simpler I really mean faster than having to go through a build system, since it has to compile, build a package, and then get it deployed. It's not really great when you want to have a quick feedback on a script you're writing, and the current ops are quiet used to this, so having to go through a longer loop would be annoying.

If you're using go in your company with this kind of setup, I'll be interested in feedback, feel free to contact me by [email](mailto:franck.cuny@gmail.com), on [Twitter](https://twitter.com/franckcuny) or [Google+](https://plus.google.com/+franckcuny).
