---
layout: post
summary: In which I share how I manage my dotfiles.
title: Dotfiles and SCM
---

All my dotfiles are stored in a SCM. Most of the time I'm on my main computer, but I can be working on a server or a different workstation. In this case, I like to have all my configurations for zsh, vim, screen, etc.

So, instead of copying my files over different computers, I put everything in a private repostiroy, and when I'm on a new computer, I just have to checkout it.  If I do a modification on a machine, I just need to commit it, and I can have the modification everywhere else.

I've got a $HOME/dotfiles directory, which is versionned (with git in my case). All my configurations file are stored here.

In this directory, as I'm avery lazy person, I've created a Makefile. Each time I create a new file, I add it to the makefile at the same time. The content of the Makefile is the following:

{% highlight make %}
DOTFILES := $(shell pwd)
all: shell  code perl plagger web
shell:
    ln -fs $(DOTFILES)/zshrc          ${HOME}/.zshrc
    ln -fns $(DOTFILES)/zsh.d       ${HOME}/.zsh.d
    ln -fs $(DOTFILES)/inputrc      ${HOME}/.inputrc
    ln -fs $(DOTFILES)/screenrc     ${HOME}/.screenrc
    ln -fns $(DOTFILES)/screen      ${HOME}/.screen
    ln -fs $(DOTFILES)/profile      ${HOME}/.profile
    ln -fs $(DOTFILES)/gnupg          ${HOME}/.gnupg code:
    ln -fs $(DOTFILES)/vimrc           ${HOME}/.vimrc
    ln -fs $(DOTFILES)/gvimrc        ${HOME}/.gvimrc
    ln -fns $(DOTFILES)/vim          ${HOME}/.vim
    ln -fs $(DOTFILES)/ackrc           ${HOME}/.ackrc
    ln -fs $(DOTFILES)/gitignore ${HOME}/.gitignore
    ln -fs $(DOTFILES)/gitconfig ${HOME}/.gitconfig
    ln -fs $(DOTFILES)/psqlrc        ${HOME}/.psqlrc perl:
    ln -fs $(DOTFILES)/proverc    ${HOME}/.proverc
    ln -fs $(DOTFILES)/pause      ${HOME}/.pause
    ln -fs $(DOTFILES)/perltidyrc ${HOME}/.perltidyrc
    ln -fns $(DOTFILES)/module-starter ${HOME}/.module-starter plagger:
    ln -fns $(DOTFILES)/plagger ${HOME}/.plagger web:
    ln -fns $(DOTFILES)/irssi                 ${HOME}/.irssi
    ln -fns $(DOTFILES)/vimperator  ${HOME}/.vimperator
    ln -fs $(DOTFILES)/vimperatorrc ${HOME}/.vimperatorrc
    ln -fs $(DOTFILES)/flickrrc       ${HOME}/.flickrrc
    ln -fs $(DOTFILES)/rtorrent.rc  ${HOME}/.rtorrent.rc
{% endhighlight %}

So next time I want to deploy my dotfiles on a new computer, I can run `make all` or `make perl code vim` and I can start coding some perl with vim.
