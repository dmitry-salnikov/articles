Keep your .zshrc simple. Mine looks like this :

``` sh
autoload -U compinit zrecompile
zsh_cache=${HOME}/.zsh_cache
mkdir -p $zsh_cache
compinit -d $zsh_cache/zcomp-$HOST
for f in ~/.zshrc $zsh_cache/zcomp-$HOST; do
    zrecompile -p $f && rm -f $f.zwc.old
done
setopt extended_glob
for zshrc_snipplet in ~/.zsh.d/S[0-9][0-9]*[^~] ; do
    source $zshrc_snipplet
done
function history-all { history -E 1 }
```

and then, in my **.zsh.d** directory, I've got:

* S10_zshopts
* S20_environment
* S30_binds
* S40_completion
* S50_aliases
* S60_prompt
* S71_ssh
* S72_git

All my aliases are in the same file, it's much easier to search/find/add.
