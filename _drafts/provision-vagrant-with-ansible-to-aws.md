---
title: Provision a AWS server with Vagrant and Ansible
summary: In which I provision a AWS server using Vagrant and Ansible
layout: post
---

I have a private repository with all my rules for ansible. You'll need a simple playbook with the following content:

```yaml
miranda ~/code/git/shiro λ more vagrant.yml
-
  hosts: all
  sudo: yes
  vars_files:
    - vars/defaults.yml
  roles:
    - common
```

First let's try our setup with a local box: `vagrant box add precise64 http://files.vagrantup.com/precise64.box`.

Now we can create a Vagrantfile:

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.ssh.forward_agent = true

  config.vm.provision "ansible" do |ansible|
    ansible.playbook = ENV['VAGRANT_ANSIBLE_PLAYBOOK']
  end
end
```

If we run `vagrant up`, a box will be started and provisioned. Once it's done, you can run `vagrant ssh` and once logged inside the VM, run `htop`.

Now let's move to the configuration for AWS. `vagrant plugin install vagrant-aws`. Then `vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box`.
