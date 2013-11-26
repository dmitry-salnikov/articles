---
layout: post
summary: In which we customize our MySQL prompt
title: Customize your MySQL prompt
---

To customize your MySQL prompt, create a .my.cnf file in your $HOME then add the following:

{% highlight sh %}
[mysql]
prompt="\\u [\\d] >"
{% endhighlight %}

Your prompt will now looks like this: `username [dabatases_name] >`
