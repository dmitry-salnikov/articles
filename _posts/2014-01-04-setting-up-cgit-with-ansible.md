---
layout: post
title: Setting up cgit with Ansible
summary: In which I share how I install cgit with Ansible.
type: codex
---

I've [already write](/ansible-and-chef/) about [Ansible](http://www.ansibleworks.com/). I use it to manage and configure my servers (most of them are VMs running on my laptop, but the idea is the same). One of the server is used to store my personal git repositories, and I wanted to use [cgit](http://git.zx2c4.com/cgit/) as the front end for the public repositories instead of the old and slow [gitweb](https://git.wiki.kernel.org/index.php/Gitweb).

Since there's no package in Debian for cgit, I need to have an easy procedure to install it. I'll show how I do it with Ansible. This could be useful if you're learning about Ansible are you're looking for a simple use case.

## Work directory

The work directory contains a bunch of files:

 * $workdir/hosts - local inventory with all the hosts, grouped by categories
 * $workdir/$hostname.yml - play book for a given host (more about this file later)
 * $workdir/roles/git - directory containing templates, tasks and handlers for installing cgit
 * $workdir/vars/$hostname.yml - contains all the variable needed to install cgit

> Replace $hostname with the name of the host you want to use for cgit.

## Handlers

In my case, cgit is hosted behind Nginx, so first, we need a handler to restart it after changing Nginx's configuration.

```yaml
# roles/git/handlers/main.yml
- name: restart nginx
  service: name=nginx state=restarted
```

## Roles

Now we need to define our role for cgit. The idea is to install the required packages to be able to build cgit, to create the directories where we will store our repositories, and actually build cgit.

{% highlight yaml %}
# roles/git/tasks/main.yml
- name: Set the directory for public repos
  file: path=/srv/git/public
        owner=www-data
        group=www-data
        mode=0770 recurse=yes
        state=directory

- name: Set the directory for private repos
  file: path=/srv/git/private
        owner=www-data
        group=www-data
        mode=0770
        recurse=yes
        state=directory

- name: Install necessities for cgit
  apt: pkg={% raw  %}{{ item }}{% endraw %} state=installed
  with_items:
    - build-essential
    - autoconf
    - automake
    - libtool
    - libfcgi-dev
    - libssl-dev
    - spawn-fcgi
    - highlight
    - fcgiwrap

- name: Create cgit web directory
  file: path=/srv/www/{% raw  %}{{ cgit_subdomain }}.{{ domain }}{% endraw %}
        recurse=yes
        state=directory
        owner=www-data

- name: Download cgit tarbal
  get_url: url=http://git.zx2c4.com/cgit/snapshot/cgit-0.9.2.zip
           dest=/tmp/cgit-0.9.2.zip
           force=no

- name: Unzip cgit
  command: unzip -qo /tmp/cgit-0.9.2.zip -d /tmp

- name: Configure cgit installation
  template: src=cgit.conf.j2 dest=/tmp/cgit-0.9.2/cgit.conf

- name: Install cgit
  shell: make get-git && make && make install chdir=/tmp/cgit-0.9.2

- name: Set permissions for cgit
  file: path=/srv/www/{% raw %}{{ cgit_subdomain }}.{{ domain }}{% endraw %}
        owner=www-data
        state=directory
        recurse=yes

- name: Configure the nginx HTTP server for cgit
  template: src=etc_nginx_sites-available_cgit.j2
            dest=/etc/nginx/sites-available/{% raw %}{{ cgit_subdomain }}.{{ domain }}{% endraw %}
            group=www-data
            owner=www-data

- name: Configure cgit
  template: src=etc_cgitrc.j2
            dest=/etc/cgitrc
            group=www-data
            owner=www-data

- name: Enable cgit
  file: src=/etc/nginx/sites-available/{% raw %}{{ cgit_subdomain }}.{{ domain }}{% endraw %}
        dest=/etc/nginx/sites-enabled/{% raw %}{{ cgit_subdomain }}.{{ domain }}{% endraw %}
        state=link
        group=www-data
        owner=www-data
  notify: restart nginx

- name: Backup git directory
  template: src=etc_cron.hourly_git-backup.j2
            dest=/etc/cron.hourly/git-backup
            mode=0755
{% endhighlight %}

## Templates

We need a bunch of templates to configure and build our tools. Let's start with **cgit.conf**.

```sh
# roles/git/templates/cgit.conf.j2

CGIT_SCRIPT_PATH = /srv/www/{% raw %}{{ cgit_subdomain }}.{{ domain }}{% endraw %}
```

This file is used when we build cgit to install it to a specific location.

The next template is to configure cgit.

```ini
# roles/git/templates/etc_cgitrc.j2

root-desc=Franck Cuny's projects
virtual-root=/
logo=/cgit.png
css=/cgit.css
scan-path=/srv/git/public
remove-suffix=1
clone-prefix=http://git.$hostname.net
```

This template is to configure nginx.

```nginx
# roles/git/templates/etc_nginx_sites-available_cgit.j2

server {
    listen 80;
    server_name  "{% raw %}{{ cgit_subdomain}}.{{ domain }}{% endraw %}";
    root /srv/www/{% raw %}{{ cgit_subdomain }}.{{ domain }}{% endraw %};

    location / {
         try_files $uri @cgit;
    }

    location @cgit {
        index cgit.cgi;

        fastcgi_param  SCRIPT_FILENAME    $document_root/cgit.cgi;

        fastcgi_pass unix:/run/fcgiwrap.socket;
        fastcgi_param HTTP_HOST $server_name;
        fastcgi_param PATH_INFO $uri;
        fastcgi_param QUERY_INFO $uri;
        include "fastcgi_params";
    }

    error_log         /var/log/nginx/{% raw %}{{ cgit_subdomain }}.{{ domain }}-error.log{% endraw %};
    access_log        /var/log/nginx/{% raw %}{{ cgit_subdomain }}.{{ domain }}-access.log{% endraw %};
}
```

## Backing up on s3

I backup all my git repositories to a bucket on s3. In order to do that, you'll need either a new role or to update the current one by adding the following instructions.

```yaml
- name: Install s3cmd
  apt: pkg=s3cmd

- name: Configure s3cmd
  sudo: false
  template:
    src="s3cfg.j2"
    dest="/root/.s3cfg"

- name: Backup git directory
  template: src=etc_cron.hourly_git-backup.j2
            dest=/etc/cron.hourly/git-backup
            mode=0755
```

We need a template to configure our access to s3.

```ini
[default]
access_key = {% raw %}{{ aws_access_key }}{% endraw %}
secret_key = {% raw %}{{ aws_secret_key }}{% endraw %}
use_https = True
```

And another template for our cron job.

```sh
#!/bin/sh
s3cmd sync -v /srv/git/ s3://$hostname-backup/git/ > /tmp/s3_backup_git.log 2>&1
```

## Variables

I have a file named **vars/$hostname.yml** that contains the

```yaml
domain: $hostname.net
cgit_subdomain: git

aws_access_key: access-key
aws_secret_key: secret-key
```

## Play time

The content of the playbook

```yaml
- hosts: $hostname
  vars_files:
    - vars/$hostname.yml
  roles:
    - git
```

Now I can tell Ansible to run this playbook, and this will install cgit on my server: `ansible-playbook -i hosts lj.yml`.
