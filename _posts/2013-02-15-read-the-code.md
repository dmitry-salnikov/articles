---
layout: post
category: devops
title: Read the code
---

The other day we had an interesting conversation at work.  We were investigating Riemann, and we started to talk what it means to adopt this technology in our stack.  Riemann is writen in Clojure, and no one at work is familiar with this language, or any other lisp (except for me, and I don't consider myself being fluent in it).

So we started to talk about what it means to have only one person who can read the code, maybe add feature, find and fix bugs, etc.  One of us pointed that we don't have to be expert with the source code of the stuff that we use.  I mean, I've never read the code of MySQL, I've read only some part of Apache's code, and I've never looked at Linux.  But at the same time, I usually read the code of the Perl and Python libraries I use frequently, and we also looked at the source of statsd and Graphite, in order to understand what they were doing, and find issues/bugs.

Then our question drifted to "when do we have to be expert in something ?".  I think that there's many answer to this question.

As a developper, you *have* to be able to read and understand the code of the libraries you depend on (we've found some serious issues with libraries like httplib2 that way).

For services you rely on in your infrastructure, it depends of the size of the tool and it's community.  For something new, or when the documentation is not good enough, or the community is rather small, it's a good thing to be able to look at the code and explain what it does.  When the project is bigger (MySQL, Riak, etc), I think you can ignore the source, and rely more on the community if it exists and is mature.
