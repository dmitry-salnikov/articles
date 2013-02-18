---
layout: post
category: emacs
title:  Emacs modes
---

For Christmas, I'll share a few modes for Emacs I've discovered
lately.

In the past few years, a few kit for Emacs have appears.  The first
one was the Emacs Starter Kit (by technomancy), followed by Emacs
Prelude and the last one is Emacs Live.  I don't use any of them,
since I've my own configuration crafted the way I like, but from time
to time I take a look at them to see what's new and what I can steal.

I'm using Emacs on OSX, but I assume that most of the modes and
example in this article will work at least for Linux.

## Packaging

Since version 24, Emacs come with a packaging system.  The official
repository is Elpa, but you can add other repositories

 * [Marmalde](http://marmalade-repo.org)
 * [MELPA](http://melpa.milkbox.net)

In your configuration, add the following code:

..code
(require 'package)

(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)

(package-initialize)

Now, if you want to install a package:  M-x package-instal {name}.  If
you don't know what to install, a simple M-x package-list-packages
will open a new buffer with all the packages available in the
repositories you've selected.

If you're using multiple computers and you share you're configuration
between them, an easy solution is to list all the packages you want to
be installed  everywhere:

..code
(defvar my-packages
  '(magit
    paredit
    rainbow-delimiters
    rainbow-mode
    helm
    helm-projectile
    clojure-mode
    diminish
    nrepl
    exec-path-from-shell
    highlight-parentheses
    auto-complete
    markdown-mode
    tango-2-theme
    cyberpunk-theme
    popwin
    yasnippet
    helm-c-yasnippet
    yaml-mode
    ruby-block
    ruby-end
    ruby-tools
    inf-ruby
    yari)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))


## Helm mode

I've been using ido for a long time now.  I knew about anything.el,
and I've probably tried it in the past.  This project has been
renamed to Helm, and it's much much better.  You could replace
entirely ido with it, but I've been using it as a complement.  ido is
good to open/find files/buffers, but if you're working on a project,
Helm is more suited for that case.

## auto-complete

This one (and the next one) took me some time to decide I wanted to
use them.  I've never been a big fan of auto completion stuff, and for
what I want, hippie-expand is generally good enough.  But the video
for [Overtone](http://vimeo.com/22798433) convinced me to give it a
try, and I don't regret it.

## yasnippet



