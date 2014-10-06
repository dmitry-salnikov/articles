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

```yaml
-
  hosts: all
  sudo: yes
  tasks:
    - name: Install htop
      apt: pkg=htop state=installed
```

What we're describing, is that for all the hosts in our inventory we will use `sudo` to install the program `htop` using `apt-get` (yes, I assume you're using a debian-based system, but you get the idea).

First, we will try the setup on a local box. If you don't already have a Vagrant box installed, you can grab a new one by running `vagrant box add precise64 http://files.vagrantup.com/precise64.box`.

Now we can add the configuration file named *Vagrantfile* with this content.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.ssh.forward_agent = true
  config.vm.provision :ansible, :playbook => "playbook.yml"
end
```

This file says that we will use the box named *precise64*, located at the given URL, and we want to provision it using Ansible, and the path to the playbook.

By running `vagrant up`, a box gets started and provisioned. An inventory file is generated for us inside the directory, so ansible will know what to do. The output should be similar to this:

```
Bringing machine 'default' up with 'virtualbox' provider...
[default] Importing base box 'precise64'...
[default] Matching MAC address for NAT networking...
[default] Setting the name of the VM...
[default] Clearing any previously set forwarded ports...
[default] Clearing any previously set network interfaces...
[default] Preparing network interfaces based on configuration...
[default] Forwarding ports...
[default] -- 22 => 2222 (adapter 1)
[default] Booting VM...
[default] Waiting for machine to boot. This may take a few minutes...
[default] Machine booted and ready!
[default] Mounting shared folders...
[default] -- /vagrant
[default] Running provisioner: ansible...

PLAY [all] ********************************************************************

GATHERING FACTS ***************************************************************
The authenticity of host '[127.0.0.1]:2222 ([127.0.0.1]:2222)' can't be established.
RSA key fingerprint is 50:db:75:ba:11:2f:43:c9:ab:14:40:6d:7f:a1:ee:e3.
Are you sure you want to continue connecting (yes/no)? yes
ok: [default]

TASK: [Install htop] **********************************************************
changed: [default]

PLAY RECAP ********************************************************************
default                    : ok=2    changed=1    unreachable=0    failed=0
```

As we can see, everything went well, and the application `htop` was successfully installed. We can now run `vagrant ssh` and once logged inside the VM, run `htop`.

</section>

<figure>
<img alt="provisioning" src="/static/imgs/vagrant-ansible-ec2.webp" Width="100%" height="100%" class='portrait' align='center'>
</figure>

<section>

## AWS

I've created a key pair for Vagrant in the AWS console. Note the access and secret access keys, and download the SSH private key too. For this article, we will put the key into the same directory as our playbook and Vagrant's configuration.

We need to install a plugin for that: `vagrant plugin install vagrant-aws`. We also need to modify our *Vagrantfile* to use a different box, and also add the configuration for AWS.

```ruby
Vagrant.configure("2") do |config|
  config.vm.provision :ansible, :playbook => 'playbook.yml'

  # This configuration is for our local box, when we use virtualbox as the provider
  config.vm.provider :virtualbox do |vb, override|
    override.vm.box = "precise64"
    override.vm.box_url = "http://files.vagrantup.com/precise64.box"
  end

  # This configuration is for our EC2 instance
  config.vm.provider :aws do |aws, override|
    aws.access_key_id = "access key"
    aws.secret_access_key = "secret access key"
    # ubuntu AMI
    aws.ami = "ami-e7582d8e"
    aws.keypair_name = "vagrant"
    aws.security_groups = ["default", "quicklaunch-1"]

    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "vagrant.pem"
  end
end
```

We need to override the user name to *ubuntu* and specify the path to the private key (the one we got from the AWS console when we created our new key pair) to log into the instance. The box also needs to be overridden.

Running `vagrant up --provider=aws` will provision the box. It will takes a few minutes to start the instance and run the provisioning part. Wait a few minutes, but if it looks like the system is stuck, you can re-run the previous command by exporting `VAGRANT_LOG=debug` in order to get more detailed information.

> If the provisioning blocks while trying to connect to ssh, it's probably because your security group doesn't allow SSH connections.

Now `vagrant ssh` will dump you into the VM and you should be able to run `htop`.

Don't forget to run `vagrant halt` and `vagrant destroy` once you're done!
