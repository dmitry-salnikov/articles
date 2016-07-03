---
date: 2008-12-05T00:00:00Z
summary: In which I share another snippet of code for vim.
title: vim and git
---

idea from [Ovid's journal](http://use.perl.org/use.perl.org/_Ovid/journal/37966.html) (ovid is full of really good ideas for vim):

to get a quick git diff in my vim session, put this in your .vimrc

```vim
map ,gh   :call SourceDiff() " gh for git history

function! SourceDiff()
    let filename = bufname("%")
    let command = 'git log -5 --pretty=format:"%h - (%ar) %an - %s" "'.filename.'"'
    let result   = split( system(command), "\n" )

    if empty(result)
    echomsg("No past revisions for " . filename)
    return
    endif

    " get the list of files
    let revision = PickFromList('revision', result)

    if strlen(revision)
        let items = split(revision, " ")
        execute '!git diff ' . items[0] . ' -- "' . filename .'" | less'
    endif
endfunction
```

the output looks like this:

    Choose a revision:
    1: ea0bb4d - (3 days ago) franck cuny - fix new_freq
    2: a896ac7 - (5 weeks ago) franck cuny - fix typo
    3: c9bc5fd - (5 weeks ago) franck cuny - update test
    4: e9de4be - (5 weeks ago) franck cuny - change the way we rewrite and check an existing url
    5: 3df1fd6 - (7 weeks ago) franck cuny - put id category

You choose the revision you want to check the diff against, and you got a (colorless) diff in your vim buffer.
