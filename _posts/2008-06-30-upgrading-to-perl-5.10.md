---
layout: post
summary: In which we upgrade to Perl 5.10.
title: Upgrading to perl 5.10
---

Get the list of your installed 5.8 modules:

{% highlight sh %}
% perl -MExtUtils::Installed -e'print join("\n", new ExtUtils::Installed->modules)' > module.list
{% endhighlight %}

then install Perl 5.10:

{% highlight sh %}
% wget http://www.cpan.org/src/perl-5.10.0.tar.gz
% tar xzf perl-5.10.0.tar.gz
% cd perl-5.10.0
% sh Configure -de -Dprefix=/opt/perl -Duserelocatableinc
% make && make test
% sudo make install
% /opt/perl/bin/perl -e 'use feature qw(say); say "hi"'
{% endhighlight %}

and then re-install your modules with `cpan \`cat module.list\``.
