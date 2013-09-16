---
layout: post
title: On how to use vim as a personal wiki
summary: In which I describe how I use vim as a personal wiki.
---

There is different reasons to want a personal wiki on your machine:

* privacy
* having it everywhere

I've tested a few wikis engines, like tiddlywiki, but I've found nothing that was really what I wanted. The main inconveniance is the need to use a webbrowser. A browser is not a text processor, so it's really painfull to use them for writing.

I've started to try to use vim as wiki. Why would I want to use something like vim for this ? well, it's plain text (easy to grep, or to write script for manipulating data), application independent, it's a real text processor, you can customize it, and most importantly, I know how to use it, ...

I've got a **wiki** directory in my home directory, with all my files in it.  I use git to track versions of it (you can use svn if you prefer, there is no difference for this usage). In my .vimrc, i've added this instruction: `set exrc`.

In my wiki directory, i've got another .vimrc with some specific mapping:

    map ,I  <esc>:e index.mkd <cr>
    map ,T  <esc>:e todo.mkd <cr>
    map ,S  <esc>:e someday.mkd <cr>
    map ,c  <esc>:s/^ /c/<cr>
    map ,w  <esc>:s/^ /w/<cr>
    map ,x  <esc>:s/^ /x/<cr>
    map gf :e <cfile>.mkd<cr> " open page
    map <backspace> :bp<cr>
    imap \date <c-R>=strftime("%Y-%m-%d")<cr>
    set tabstop=2                   " Number of spaces <tab> counts for.
    set shiftwidth=2                " Unify
    set softtabstop=2               " Unify

I organize my files in directory. I've got a *work*, *lists*, *recipes*, *misc*, ... and I put my files in this directory.

I've got an index page, with links to main section. I don't have wikiword in camelcase or things like that, so if i want to put a link to a page, I just wrote the link this way **dir_name/page_name**, then, i juste have to hit **gf** on this link to open the page.  I also use this place as a todo list manager. I've got one paragrah per day, like this : 

```
2008-06-14
 - [@context] task 1
 - [@context] task 2
 ...
```

and a bunch of vim mapping for marking complete (**,c**), work in progress (**,w**) or canceled (**,x**).

If i don't have a deadline for a particular task, I use a 'someday' file, where the task is put with a context.

The good things with markdown, is that the syntax is easy to use, and it's easy to convert to HTML.
