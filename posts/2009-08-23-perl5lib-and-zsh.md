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
