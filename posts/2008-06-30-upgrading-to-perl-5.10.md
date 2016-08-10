Get the list of your installed 5.8 modules:

``` bash
perl -MExtUtils::Installed -e'print join("\n", new ExtUtils::Installed->modules)' > module.list
```

then install Perl 5.10:

``` bash
wget http://www.cpan.org/src/perl-5.10.0.tar.gz
tar xzf perl-5.10.0.tar.gz
cd perl-5.10.0
sh Configure -de -Dprefix=/opt/perl -Duserelocatableinc
make && make test
sudo make install
/opt/perl/bin/perl -e 'use feature qw(say); say "hi"'
```

and then re-install your modules with cpan \`cat module.list\`.
