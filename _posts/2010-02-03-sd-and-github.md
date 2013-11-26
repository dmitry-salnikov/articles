---
layout: post
summary: In which I share how to use SD with GitHub
title: SD and github
---

If you are using the version of <a href="http://syncwith.us/">SD</a> hosted on <a href="http://github.com/bestpractical/sd">GitHub</a>, you can now clone and pull issues very easily. First,

{% highlight sh %}
$ git config --global github.user franckcuny
$ git config --global github.token myapitoken
{% endhighlight %}

This will set in your <strong>.gitconfig</strong> your github username and api token. Now, when you clone or pull some issues using sd:

{% highlight sh %}
$ git sd clone --from github:sukria/Dancer
{% endhighlight %}

sd will check your .gitconfig to find your credentials.
