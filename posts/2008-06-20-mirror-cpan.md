For the last 10 months, I've been living with no internet connection at home (not on purpose, but this is another story), so I've tried to be as much as possible independent from the web. I've started to use git for being able to work off-line, I use Vim as a wiki on my computer, my blog engine for writing post off-line, ...

As as perl developer, I use a lot the CPAN. So, I've start to mirror the CPAN on my computer. Here is how:

First, you will need the minicpan: `cpan CPAN::Mini`.

Then, edit a **.minicpanrc** file and add the following:

```sh
local: /path/to/my/mirror/cpan
remote: ftp://ftp.demon.co.uk/pub/CPAN/
```

And to finish, add this in your crontab:

```sh
5 14 * * * /usr/local/bin/minicpan > /dev/null 2>&1
```

Everyday, at 14h05, your cpan will be updated.

Now use the CPAN cli: `sudo cpan` and execute the following command `cpan[1]> o conf urllist unshift file:///path/to/my/mirror/cpan`

And voilà, I've got my own minicpan on my computer, so I can install everything when I need it, being off-line or not.
