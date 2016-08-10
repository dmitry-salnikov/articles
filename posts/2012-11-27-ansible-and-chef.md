I've been using [Chef](http://www.opscode.com/chef/) for some time now, but it was always via [Vagrant](http://vagrantup.com), so a few weeks ago I decided to get more familiar with it. A friend of mine had set up a Chef server for his own use and was OK to let me use it for my personal server. There was a four days weekend for Thanksgiving coming, so it was the perfect occasion to take a better look at it, and to re-install my Linode server with Chef. And since it was a really long weekend, I also decided to take a look at [ansible](http://ansible.cc), another tool to push stuff to your server.

I'm not going to talk about installation, configuration, set up and all that kind of stuff, there's enough material available around (blog posts, articles, books, etc). Instead, I will talk about my experience and share my (very valuable) opinion (because, clearly, the world deserve to know what I think).

## Writing cookbooks for Chef

For the few of you who don't know, cookbooks, in Chef's world, are a group of files (templates, static files) and code that are used to automate your infrastructure. Usually, you'll create a cookbook for each of your application (one for nginx, one for MySQL, etc).

I've a few services on my server (git, gitolite, Jenkins, graphite, collectd, phabricator, ...), and I wanted a coobook for each of them. I've started by looking for the one already existing (there's a lot of them on GitHub, on the [opscode's account](https://github.com/opscode-cookbooks/)), and I tried to use them without any modification. Usually, a cookbook will let you set some configuration details in your role or node to override the defaults it provides (like the password for MySQL, or the path where to put logs). So what I did was to set the interesting cookbook as a git submodule in my cookbook repository. Unfortunately, for almost all of them, I had to give up and import them in the repo, so I could edit and modify them.

That's probably my biggest complaint with cookbooks: I doubt code re-usability is possible. You can use a cookbook as a base for your own version, but either they are too generic; or sometimes you need a workaround; or they do way too many things. And as a result, you need to edit the code to make them behave the way you want.

In my opinion, developers/ops should just publish [LWRP](http://docs.opscode.com/essentials_cookbook_lwrp.html) (Lightweight Resources and Providers) and templates, that's the only thing that I can see as really re-usable (take a look at [perl-chef](https://github.com/dagolden/perl-chef), I think that this one is a good example).

## Using ansible

ansible was a new tool for me. A few friends mentionned it to me last October when I was at the [OSDC.fr](http://osdc.fr) and it was also suggested to me by a colleague at work.

This tool is definitely less known that Chef, so I'll give a quick introduction. In ansible world, you write "playbooks", which are the orchestration language for the tool. That sounds very similar with Chef, but the main difference is they are not actual code, but a scenario with actions.

On the web site of the project, there's a quote saying:

> You can get started in minutes.

and for once, that's true. I only had to read the first page of the documentation, and I was able to write a very simple playbook that I was able to evolve very quickly to do something actually useful.

Another difference with Chef is that they don't incite you to share your playbooks, but instead to share your modules. Modules could be compared to Chef's LWRP. They are Python code to do something specific (like the [`pip`](http://ansible.cc/docs/modules.html#pip) module, to install Python package, or the [`template`](http://ansible.cc/docs/modules.html#template)'s one).

## Chef vs Ansible

For now, I've decided to stick to this: use Chef for my supporting application (nginx, MySQL, etc) and ansible for my own applications.

So far, I prefer ansible to Chef. There's definitely less available material about ansible on the net, but the quality is better, and the main documentation is very (I insist on the *very*) well organized. I've never spend more than 10 minutes looking for something and to implement it. I can't say the same with Chef: the wiki is confusing; there's way too many cookbooks available; their quality is very disparate.
