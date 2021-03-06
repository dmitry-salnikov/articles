## tl;dr

I've been toying with [vagrant](http://vagrantup.com/) lately, and it **really rocks**. You should definitly give it a try. If you're only looking for some resources to get started with it, go there:

-   [introduction](http://docs.vagrantup.com/v2/why-vagrant/)
-   [google group](http://groups.google.com/group/vagrant-up)

## What is Vagrant

"Vagrant is a tool for building and distributing virtualized development environments." This sentence summarizes perfectly the project.

The idea is to use [Chef](http://www.opscode.com/chef) on top of [VirtualBox](http://www.virtualbox.org/) to deploy a VM like you would deploy a server in your production environment.

I won't go into the details to describe Chef and VirtualBox, but here is a quick reminder. Chef is a framework to deploy infrastructures. It's written in ruby, it uses **cookbooks** to describe how to deploy stuff, and VirtualBox is a virtualization software from Oracle.

> A little disclaimer. I don't use Chef outside from vagrant, so I may say/do some stupid things. The aim of this tutorial is not about writing a recipe for Chef, but to show what you can do thanks to Chef. So don't hesitate to correct me in the comments if I'm doing some utterly stupid things.

## The basic

To install vagrant, you'll need ruby and virtualbox. You have the basic instructions detailed [here](http://docs.vagrantup.com/v2/getting-started/). This will explain how to install vagrant and how to fetch a **base** image.

### Creating a first project

You'll probably want to start creating a new project now. For this tutorial, I'll create an image for [presque](https://github.com/franckcuny/presque).

``` bash
mkdir presque
vagrant init
```

This will create a new image for your project, and create a new file in your directory: **Vagrantfile**. Modify this file to make it look like this:

``` ruby
Vagrant::Config.run do |config|
  config.vm.box = "base"
  config.vm.provisioner = :chef_solo
  config.chef.cookbooks_path = "cookbooks"
  config.chef.add_recipe("vagrant_main")
  config.vm.forward_port("web", 5000, 8080)
end
```

These instructions will:

-   tell vagrant to use the image named **base** (a lucid32 image by default)
-   use chef in **solo** mode
-   the recipes will be in a directory named **cookbooks**
-   the main recipe will be named **vagrant\_main**
-   forward local HTTP port 4000 to 5000 on the VM

### My recipes

Now we need to create or use some recipes. First we create our **cookbooks** directory:

``` bash
mkdir cookbooks
mkdir -p cookbooks/vagrant_main/recipes
```

We need to add some cookbooks. You will find them on [GitHub](https://github.com/opscode/cookbooks). Copy the following cookbooks inside the **cookbooks** repository:

-   apt: instructions on how to use apt
-   ubuntu: this one manages the sources and executes **apt-get update**
-   build-essential: installs the build-essential package
-   git: installs git
-   perl: configures CPAN
-   runit: will be used to monitor redis and our web application

Edit **vagrant\_main/recipes/default.rb** to add them:

``` ruby
require_recipe "ubuntu"
require_recipe "git"
require_recipe "perl"
require_recipe "redis"
require_recipe "runit"
```

If the VM is already started, you can run `vagrant provision` or `vagrant up`. This will deploy the previous cookbooks on the VM. When it's done, you can log on the VM with `vagrant ssh`.

You'll need to additional recipes: one for redis; one for presque. You'll find them on my [GitHub account](http://git.lumberjaph.net/chef-cookbooks.git/). Copy the two recipes inside your cookbook directory, and execute `vagrant provision` to install them.

If everything works fine, you should be able to start using presque. Test this:

``` bash
curl http://localhost:8080/q/foo/
{"error":"no job"}

curl -X POST -H "Content-Type: application/json" -d '{"foo":"bar"}' http://localhost:8080/q/foo/

curl http://localhost:8080/q/foo/
{"foo":"bar"}
```

If everything is fine, you can shut down the VM with `vagrant halt`.

### Mounting directories

Instead of pulling from github, you may prefer to mount a local directory on the VM. For this, you'll need to modifiy the **Vagrantfile** to add this:

``` ruby
config.vm.share_folder "v-code", "/deployment/code", "~/code/perl5"
config.vm.share_folder "v-data", "/deployment/data", "~/code/data"
```

This will mount your local directories **perl5** and **data** under **/deployment/{code,data}** on the VM. So now you can edit your files locally and they will be automagically updated on the VM at once.

## and now the awesome part

If you're like me, you may end up with the need to have multiple VMs which will talk to each other. Common scenarios are a VM with the website, and another one with the DB, or one VM with a bunch of API webservices and another with Workers who need to interact with the VM. Rejoice, this kind of stuff is also handled by vagrant!

Replace the content of the previous **Vagrantfile** with this:

``` ruby
Vagrant::Config.run do |config|
  config.vm.box = "base"
  config.vm.provisioner = :chef_solo

  config.chef.cookbooks_path = "cookbooks"

  config.vm.define :presque do |presque_config|
    presque_config.chef.add_recipe("vagrant_presque")
    presque_config.vm.network("192.168.1.10")
    presque_config.vm.forward_port("presque", 80, 8080)
    presque_config.vm.customize do |vm|
      vm.name = "vm_presque"
    end
  end

  config.vm.define :workers do |workers_config|
    workers_config.chef.add_recipe("vagrant_workers")
    workers_config.vm.network("192.168.1.11")
    workers_config.vm.customize do |vm|
      vm.name = "vm_workers"
    end
  end
end
```

In this configuration, we're creating two VMs, **presque** and **workers**. You'll need to create two new cookbooks, one for each new VM (vagrant\_presque, with the same content as vagrant\_main, and vagrant\_workers, with only the recipe for ubuntu and the instructions to install curl). Once it's done, boot the two VMs:

``` bash
vagrant up presque
vagrant up workers
```

Now let's log on the worker VM

``` bash
vagrant ssh workers
vagrant@vagrantup:~$ curl http://192.168.1.10:5000/q/foo
{"error":"no job"}
```

and voilà.

## Conclusion

I've started to use vagrant for all my new personal projects and for most of my stuff at work. I really enjoy using this, as it's easy to create a cookbook or add one, it's easy to setup a multi VM environment, you can share a configuration amongst your coworkers, etc.

If you haven't started yet using a VM for your own projects, you really should give it a try, or use a simple VirtualBox setup. If you want to read more on the subject, these two blog posts may be relevant:

-   [Why you should be using virtualisation](http://morethanseven.net/2010/11/04/Why-you-should-be-using-virtualisation.html)
-   [nothingmuch setup](http://blog.woobling.org/2010/10/headless-virtualbox.html)

(oh, and BTW, did you notice that [Dancer 1.2](http://search.cpan.org/perldoc?Dancer) is out ?)
