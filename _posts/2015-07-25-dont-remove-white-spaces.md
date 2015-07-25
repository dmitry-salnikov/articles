---
layout: post
title: Don't blindly remove trailing white spaces
summary: In which I explain why removing blindly white spaces is harmful
---

I don't like trailing white spaces in my source code. I've configured my editors to highlight them
so I don't add them by accident, and when possible, I remove them. But it doesn't mean that all of
them should be removed blindly.

In this post, I'm talking about files that are managed by a SCM. When working on such a text file,
editor's hooks that delete them when writing a file can be more annoying than keeping them in place.
A change should only touch lines that are relevant to the fix or feature beeing added. Touching
lines that are not relevant are creating noise in the history. I've made this mistake in the past,
and I've learned my lessons.

## Pain for the reviewer

The person who will review the change will have to make an extra effort to understand why the diff
highlight some lines where it looks like there's no change. It's a distraction to his main task, and
it doesn't bring any benefit to the change beeing submitted.

## Pain for the person browsing the history

When someone browse the history and try to understand what changed between two versions, the
deletion is just noise. It's already hard to make the mental effort to read a diff, and understand
what and why things have changed. Adding some extra noise is annoying.

Running a tool like `git blame` shows how useless this is, for both the person reading the history
and the author.

## Tips

Configure your editor to highlight them. If you are using Emacs, you can do it with

```
(require 'whitespace)
(global-whitespace-mode 1)
(setq whitespace-style '(face trailing tabs tab-mark))
```

With vim, you can add the following:

```
set list lcs=trail:·,tab:»·
highlight ExtraWhitespace ctermbg=red guibg=red
```

It's also possible to configure `git` to highlight them when running `git add -p`, by running

```
git config --global core.whitespace trailing-space,space-before-tab
```

`git` will complain if it finds white spaces in your change, so you have time to fix and remove
them.

If you really don't want any trailing white spaces, you can also configure your SCM with a
post-commit hook to reject commits that contains them.

If you're using `vimdiff` to read a diff, it's possible to not highlight white spaces with `set
diffopt+=iwhite`. This can makes it a little bit easier to read messy diff.
