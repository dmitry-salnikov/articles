---
layout: post
title: Setting up bittorrent sync with Ansible
summary: In which I share how I install bittorrent sync with Ansible.
type: codex
---

Recently, I've started to look at the services I'm using and I'm trying to find alternatives for some of them. One of them was [Dropbox](https://www.dropbox.com/). I've been using this service for 4 or 5 years at this point, and I was a paid customer for at least 3 years. My plan was about to renew in a few days, and I decided to look for a free (either as "doesn't cost a buck" or OSS) alternative. To make it quick, since it's not the purpose of this post, I've decided to go with Bittorrent Sync. Still, this solution is not perfect, so here's a short list of pros and cons:

* Pros:
    * Free
    * The only limit on storage is based on the free space you have
    * Decentralized
* Cons
    * Harder to set up
    * Slower than Dropbox for syncing files
    * Decentralized (yes I know): you need to always have at least one node up if you want to get a copy of a file

I decided to set btsync on one of my server that is always up, that I way I can access my copies whenever I want from any devices (this is similar to Dropbox). To do that I've create a set of tasks for Ansible, following the instructions provided by [Leo Moll](https://github.com/tuxpoldo) (who created the package for Debian) on [this forum](http://forum.bittorrent.com/topic/18974-debian-and-ubuntu-server-packages-for-bittorrent-sync-121-1/).

I've created a role named 'btsync' that contains a handler, some templates and a bunch of tasks. Let's start with the handler, since this one is really simple. For this role, the only y service we care about is the bittorrent sync daemon:

```yaml
- name: restart btsync
  service: name=btsync state=restarted
```

The tasks are pretty straightforward. First we need to fetch Leo's PGP key so we can install the package using `apt`.

```yaml
- name: Install GPG key for btsync
  apt_key:
    id=6BF18B15
    state=present
    url=http://stinkfoot.org:11371/pks/lookup?op=get&search=0x40FC0CD26BF18B15
```

Now that we have the PGP key, we can add the repository to our sources and install the package:

```yaml
- name: Add the deb repo for btsync
  apt_repository:
    repo='deb http://debian.yeasoft.net/btsync wheezy main'
    state=present

- name: Install btsync
  apt: pkg=btsync state=installed
```

For the remaining tasks, we need some configuration.

```yaml
btsync_shared:
  - dir: /path/to/shared/photos
    secret: a-secret
    use_relay_server: true
    use_dht: false
    search_lan: false
    use_sync_trash: true
  - dir: /path/to/shared/documents
    secret: another-secret
    use_relay_server: true
    search_lan: false
    use_sync_trash: true
```

The daemon expect all the directories that it will write to, to exist. So let's create them for him, and also set the right permissions on them:

```yaml
- name: Create the directories where we need to sync
  file: path={{ item.dir }} state=directory owner={{ main_user_name }} group={{ main_user_name }} mode=0700
  with_items: btsync_shared
```

We need a specific configuration file for our user:

```yaml
- name: Configure btsync
  template:
    src=etc_btsync_user.conf.j2
    dest=/etc/btsync/{{ main_user_name }}.conf
    group={{ main_user_name }}
    owner={{ main_user_name }}
    mode=0600
  notify: restart btsync
```

and the template that goes with it:

```json
{
        "device_name": "{{ domain }}",
        "storage_path" : "/home/{{ main_user_name }}/.btsync",
        "listening_port" : 12589,
        "check_for_updates" : false,
        "use_upnp" : false,
        "download_limit" : 0,
        "upload_limit" : 0,
        "disk_low_priority" : true,
        "lan_encrypt_data" : true,
        "lan_use_tcp" : false,
        "rate_limit_local_peers" : false,
        "folder_rescan_interval" : 600,
        "shared_folders" : {{ btsync_shared | to_json }}
}
```

To complete the setup, we need to tell the daemon to start with our newly created configuration:

```sh
# This is the configuration file for /etc/init.d/btsync
#
# Start only these btsync instances automatically via
# init script.

AUTOSTART="{{ main_user_name }}"

# Optional arguments to btsync's command line. Be careful!
# You should only add thngs here if you know EXACTLY what
# you are doing!
DAEMON_ARGS=""
```

Finally, the task to setup the default configuration for the daemon:

```yaml
- name: Configure btsync server
  template:
    src=etc_default_btsync.j2
    dest=/etc/default/btsync
    group=root
    owner=root
  notify: restart btsync
```

That's it!

I'll try to find some time this weekend to upload this to [Galaxy](https://galaxy.ansibleworks.com/).
