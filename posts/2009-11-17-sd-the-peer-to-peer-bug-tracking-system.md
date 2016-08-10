SD is a peer to peer bug tracking system build on top of Prophet. Prophet is A grounded, semirelational, peer to peer replicated, disconnected, versioned, property database with self-healing conflict resolution. SD can be used alone, on an existing bug tracking system (like RT or redmine or github) and it plays nice with git.

Why should you use SD ? Well, at $work&lt;/a&gt; we are using &lt;a href="<http://www.redmine.org/>"&gt;redmine&lt;/a&gt; as our ticket tracker. I spend a good part of my time in a terminal, and checking the ticket system, adding a ticket, etc, using the browser, is annoying. I prefer something which I can use in my terminal and edit with my &lt;a href="<http://www.vim.org/>"&gt;$EDITOR. So if you recognize yourself in this description, you might want to take a look at SD.

> In the contrib directory of the SD distribution, you will find a SD ticket syntax file for vim.

how to do some basic stuff with sd
----------------------------------

We will start by initializing a database. By default

``` example
    % sd init
```

will create a *.sd* directory in your $HOME. If you want to create in a specific path, you will need to set the SD\_REPO in your env.

``` example
    % SD_REPO=~/code/myproject/sd sd init
```

The init command creates an sqlite database and a config file. The config file is in the same format as the one used by git.

Now we can create a ticket:

``` example
    % SD_REPO=~/code/myproject/sd ticket create
```

This will open your $EDITOR, the part you need to edit are specified. After editing this file, you will get something like this:

> Created ticket 11 (437b823c-8f69-46ff-864f-a5f74964a73f) Created comment 12 (f7f9ee13-76df-49fe-b8b2-9b94f8c37989)

You can view the created ticket:

``` example
    % SD_REPO=~/code/myproject/sd ticket show 11
```

and the content of your ticket will be displayed.

You can list and filter your tickets:

``` example
    % SD_REPO=~/code/myproject/sd ticket list
    % SD_REPO=~/code/myproject/sd search --regex foo
```

You can edit the SD configuration using the config tool or editing directly the file. SD will look for three files : *etc/sdrc, $HOME*.sdrc or the config file in your replica (in our exemple, ~/code/myproject/sd/config).

For changing my email address, I can do it this way:

``` example
    % SD_REPO=~/code/myproject/sd config user.email-address franck@lumberjaph.net
```

or directly

``` example
    % SD_REPO=~/code/myproject/sd config edit
```

and update the user section.

sd with git
-----------

SD provides a script for git: *git-sd*.

Let's start by creating a git repository:

``` example
    % mkdir ~/code/git/myuberproject
    % cd ~/code/git/myuberproject
    git init
```

SD comes with a git hook named "git-post-commit-close-ticket" (in the contrib directory). We will copy this script to .git/hooks/post-commit.

now we can initialize our sd database

``` example
    % git-sd init
```

git-sd will try to find which email you have choosen for this project using git config, and use the same address for it's configuration.

Let's write some code for our new project

``` perl
    #!/usr/bin/env perl
    use strict;
    use warnings;
    print "hello, world\n";
```

then

``` example
    % git add hello.pl
    % git commit -m "first commit" hello.pl
```

now we can create a new entry

``` example
    % git-sd ticket create # create a ticket to replace print with say
```

We note the UUID for the ticket: in my exemple, the following output is produced:

> Created ticket 11 (92878841-d764-4ac9-8aae-cd49e84c1ffe) Created comment 12 (ddb1e56e-87cb-4054-a035-253be4bc5855)

so my UUID is 92878841-d764-4ac9-8aae-cd49e84c1ffe.

Now, I fix my bug

``` example
    #!/usr/bin/env perl
    use strict;
    use 5.010;
    use warnings;
    say "hello, world";
```

and commit it

``` example
    % git commit -m "Closes 92878841-d764-4ac9-8aae-cd49e84c1ffe" hello.pl
```

If I do a

``` example
    % git ticket show 92878841-d764-4ac9-8aae-cd49e84c1ffe
```

The ticket will be marked as closed.

sd with github
--------------

Let's say you want to track issues from a project (I will use Plack for this exemple) that is hosted on github.

``` example
    % git clone git://github.com/miyagawa/Plack.git
    % git-sd clone --from "github:http://github.com/miyagawa/Plack"
    # it's the same as
    % git-sd clone --from "github:miyagawa/Plack"
    # or if you don't want to be prompted for username and password each time
    % git-sd clone --from github:http://githubusername:apitoken@github.com/miyagawa/Plack.git
```

It will ask for you github username and your API token, and clone the database.

Later, you can publish your sd database like this:

``` example
    % git-sd push --to "github:http://github.com/$user/$project"
```

Now you can code offline with git, and open/close tickets using SD :)
