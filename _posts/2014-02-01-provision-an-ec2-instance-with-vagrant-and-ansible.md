---
title: Provisioning an EC2 instance with Vagrant and Ansible
summary: In which I provision an EC2 instance with Vagrant and Ansible
layout: post
---

I like to use [Ansible](http://www.ansible.com/) to manage my personal servers. It forces me to make the environment reproducible so I don't have to care about a specific box: I can throw them away easily, knowing I can get a new one when I need, with the exact same configuration.

I also find Ansible easier to reason about than Chef or Puppet. The fact that I have to manage and maintain only a few machines is probably why.

When I develop on my personal projects, I use a lot of VMs, and that's where [Vagrant](http://www.vagrantup.com/) enters the picture. Being able to start a local VM and get a clean environment quickly is invaluable to me. It makes it easy to test an application or library in different situation, without carrying about local dependencies and conflicts created by having multiple versions of the same library installed on the system.

But sometimes a local VM is not enough, and you need a more powerful server, so now you need an EC2 instance.

My goal with this article is to show how easy you can combine Vagrant with Ansible to provision an EC2 instance.

## The basic

I have a private repository with all my rules for Ansible. But for this post, all we need is a simple playbook. So let's start by creating a directory named *vagrant*, and put inside a configuration file named *playbook.yml*, with the following content:

<script src="https://gist.github.com/franckcuny/fae46135ad0f3581ce6b.js"></script>

What we're describing, is that for all the hosts in our inventory we will use `sudo` to install the program `htop` using `apt-get` (yes, I assume you're using a debian-based system, but you get the idea).

First, we will try the setup on a local box. If you don't already have a Vagrant box installed, you can grab a new one by running `vagrant box add precise64 http://files.vagrantup.com/precise64.box`.

Now we can add the configuration file named *Vagrantfile* with this content.

<script src="https://gist.github.com/franckcuny/aadd788101c08744a22a.js"></script>

This file says that we will use the box named *precise64*, located at the given URL, and we want to provision it using Ansible, and the path to the playbook.

By running `vagrant up`, a box gets started and provisioned. An inventory file is generated for us inside the directory, so ansible will know what to do. The output should be similar to this:

<script src="https://gist.github.com/franckcuny/e3df9a2424e4a4a12f60.js"></script>

As we can see, everything went well, and the application `htop` was successfully installed. We can now run `vagrant ssh` and once logged inside the VM, run `htop`.

## AWS

I've created a key pair for Vagrant in the AWS console. Note the access and secret access keys, and download the SSH private key too. For this article, we will put the key into the same directory as our playbook and Vagrant's configuration.

We need to install a plugin for that: `vagrant plugin install vagrant-aws`. We also need to modify our *Vagrantfile* to use a different box, and also add the configuration for AWS.

<script src="https://gist.github.com/franckcuny/ac8cad84af5f51a923f6.js"></script>

We need to override the user name to *ubuntu* and specify the path to the private key (the one we got from the AWS console when we created our new key pair) to log into the instance. The box also needs to be overridden.

Running `vagrant up --provider=aws` will provision the box. It will takes a few minutes to start the instance and run the provisioning part. Wait a few minutes, but if it looks like the system is stuck, you can re-run the previous command by exporting `VAGRANT_LOG=debug` in order to get more detailed information.

> If the provisioning blocks while trying to connect to ssh, it's probably because your security group doesn't allow SSH connections.

Now `vagrant ssh` will dump you into the VM and you should be able to run `htop`.

Don't forget to run `vagrant halt` and `vagrant destroy` once you're done!
