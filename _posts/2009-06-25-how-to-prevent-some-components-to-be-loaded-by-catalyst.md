---
layout: post
summary: In which I show how to disable some components in Catalyst.
title: How to prevent some components to be loaded by Catalyst
type: codex
---

Let's say you have a large [Catalyst](http://search.cpan.org/perldoc?Catalyst) application, with a lot of compoments. When you deploy your application, or when you want to test it while your developping, you may not want to have some of thoses components loaded (you don't have all the dependencies, they are incompatible, etc...). Catalyst use [Module::Pluggable](http://search.cpan.org/perldoc?Module::Pluggable) to load the components, so you can easily configure this. In your application's configuration, add:

{% highlight yaml %}
setup_components:
  except:
    - MyApp::Model::AAAA
    - MyAPP::Model::BBBB::REST
    ...
{% endhighlight %}

Module::Pluggable have some other interesting features. You may have a second Catalyst application, and want to use one or more components from this one. You can easily do this:

{% highlight yaml %}
setup_components:
  search_path:
    - MyApp
    - MyOtherApp::Model
{% endhighlight %}
