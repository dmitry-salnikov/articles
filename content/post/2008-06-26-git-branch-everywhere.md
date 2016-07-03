---
date: 2008-06-26T00:00:00Z
summary: In which I share a snippet of code to display a git branch in vim.
title: Git branch everywhere
---

The current trend is to have the name of the current git branch everywhere. Personnaly I display it in my vim's status bar, and in my zsh prompt.

Here is my vimrc configuration for this (I'm not the author of this function, and can't remember where I saw it first):

```vim
set statusline=%&lt;[%n]%m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).':'.&ff}%{g:gitCurrentBranch}%{']'}%y\ %F%=%l,%c%V%8P
autocmd BufEnter * :call CurrentGitBranch()

let g:gitCurrentBranch = ''
function! CurrentGitBranch()
    let cwd = getcwd()
    cd %:p:h
    let branch = matchlist(system('/usr/local/git/bin/git  branch -a --no-color'), '\v\* (\w*)\r?\n')
    execute 'cd ' . cwd
    if (len(branch))
        let g:gitCurrentBranch = '][git:' . branch[1] . ''
    else
        let g:gitCurrentBranch = ''
    endif
    return g:gitCurrentBranch
endfunction
```

and my zshrc:

```vim
local git_b
git_b='$(get_git_prompt_info '%b')'
PROMPT="%(?..%U%?%u:) $git_b %40>...<%/%(#.%U>%u.%B>%b) "
```

with the following script [S55_git](http://www.jukie.net/~bart/conf/zsh.d/S55_git).
