---
date: 2008-06-17T00:00:00Z
summary: In which I add a few functions for my vim wiki.
title: Vim function for creating new task
---

I've added a new function to my .vimrc for creating quickly a new task:

```vim
function! CreateTask()
    let context = input("Enter context: ")
    exe ":set noautoindent"
    exe "normal 0"
    exe "normal o \<tab>- [@".context."]  "
    exe ":set autoindent"
    exe ":startinsert"
endfunction
```

and then this mapping: `map ct <esc>:call CreateTask()<cr>`

Now, I've just to hit `,n` and type my context. A new line will be inserted and I just have to create my task.
