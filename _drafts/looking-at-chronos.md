---
layout: post
title: Looking at Chronos
summary: In which I take a look at Chronos
---

# Looking at Chronos

I've decided to look at Chronos, a cron replacement running on Mesos.

Mesos

## Getting an environment

First I need to get an environment to play with it. Let's do that quickly with Vagrant and Ansible:

```ruby
Vagrant.configure("2") do |config|
  config.ssh.forward_agent = true

  config.vm.provision :ansible, :playbook => 'playbook.yml'

  config.vm.provider :virtualbox do |vb, override|
    override.vm.box = "precise64"
    override.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end

end
```

And the playbook for Ansible:

```yaml
  - hosts: all
    sudo: yes
    tasks:
      - name: Install a bunch of packages
        apt: pkg={{ item }} state=installed
        with_items:
          - autoconf
          - make
          - gcc
          - cpp
          - patch
          - python-dev
          - git
          - libtool
          - default-jdk
          - default-jre
          - gzip
          - libghc-zlib-dev
          - libcurl4-openssl-dev

```

Now I can run `vagrant up` and wait to get the VM build with everything I need.
