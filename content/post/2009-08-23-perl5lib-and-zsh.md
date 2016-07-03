---
date: 2009-08-23T00:00:00Z
summary: In which I show how I manage my $PERL5LIB.
title: $PERL5LIB and zsh
---

in my .zsh.d/S80_perl

```bash
BASE_PATH=~/code/work/rtgi
for perl_lib in $(ls $BASE_PATH); do
    if [ -f $BASE_PATH/$perl_lib/Makefile.PL ]; then
        PERL5LIB=${PERL5LIB:+$PERL5LIB:}$BASE_PATH/$perl_lib/lib
    fi
done
export PERL5LIB

```
