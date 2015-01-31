---
layout: post
title: On Ubuntu and a Dell XPS13
summary: In which I install Ubuntu on a Dell XPS13
---

Being fed up with Yosemite, I decided to order the new [Dell XPS13 (2015
edition)](http://www.dell.com/us/p/xps-13-9343-laptop/pd?ST=dell%20xps13&dgc=ST&cid=79646&lid=2024370&acd=123098073120560)
after reading a few reviews. I've installed Ubuntu 14.10 on it.

Installing Ubuntu was (as expected) straightforward:

* you go to the BIOS (F2 when the Dell logo shows up on screen)
* boot from an USB disk with Ubuntu (page to the instructions)
* use an ethernet -> usb adaptor since the wifi doesn’t work out of the box with the broadcom driver
* select what ever you want for the disk setup (I went with dm-crypt / llvm / btrfs)
* once it’s installed and you’re logged in as your user, install the wifi package (apt-get install bcmwl-kernel-source)

then at this point you have a “functional” laptop.

Sadly, there's still a few issues so far with Ubuntu 14.10:

* no sound (I don’t really mind for now, I use my phone/tablet to listen to music / watch youtube and stuff).  There’s a [ticket](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1413446) to track the problem
* as is the keyboard (there's a bug where a key can be repeated a few time)
* the touchpad is ... touchy. I need to hold the button down for a second before it get registered,
  and there's some kind of issues where it get lost. But I think this is fixed with newer kernel
  (need to test).

```sh
mp saved to /sys/class/drm/card0/error
[ 1835.632679] [drm] Enabling RC6 states: RC6 on, RC6p off, RC6pp off
[ 1868.702435] psmouse serio1: TouchPad at isa0060/serio1/input0 lost synchronization, throwing 1
bytes away.
[ 1869.211965] psmouse serio1: resync failed, issuing reconnect request
[ 1876.689924] psmouse serio1: TouchPad at isa0060/serio1/input0 lost synchronization, throwing 1
bytes away.
[ 1877.198899] psmouse serio1: resync failed, issuing reconnect request
[ 1879.545191] psmouse serio1: TouchPad at isa0060/serio1/input0 lost sync at byte 4
[ 1879.546318] psmouse serio1: TouchPad at isa0060/serio1/input0 lost sync at byte 1
[ 1879.558431] psmouse serio1: TouchPad at isa0060/serio1/input0 - driver resynced.
```

But there's also the good stuff!

* the screen! really awesome definition. The resolution was properly detected, didn’t tweak anything
* the keyboard is nice, however I’m looking for a solution to swap fn and control
* the battery last, I get about ~7 hours of battery life with normal usage

## Hardware

The hardware is attractive. It’s really small (smaller than the MBPr 13”, but probably a little bit
bigger than the MBA 11”). It’s light. There’s 2 USB ports, 1 SD card (that’s one of the reason I
went with this model instead of the carbon x1).

My main complaint is the 8GB limit, I would have prefered 16GB. Not having a broadcom
wireless card would have also been nice (maybe they will change this for the developer edition ?).
But (and that's the main difference with Apple :), there's a
[smanual](ftp://ftp.dell.com/Manuals/all-products/esuprt_laptop/esuprt_xps_laptop//xps-13-9343-laptop_Service%20Manual_en-us.pdf)
and instructions on how to replace the wireless card. The good alternaties seems to be the [Intel
7260](http://www.amazon.com/gp/product/B00MY9S692/) (I might replace the card).

For the curious, here’s the output of [dmesg](/files/dell-xps-2015-dmesg.txt) and
[lspci](/files/dell-xps-2015-lspci.txt).

I’ll update this page with more details / information in the next few weeks (I'm currently on a
3.16, I'll try the 3.18 during the weekend).
