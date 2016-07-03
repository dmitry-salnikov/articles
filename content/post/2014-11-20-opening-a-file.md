---
date: 2014-11-20T00:00:00Z
summary: In which I try to understand what happens when you open a file
title: On opening a file
---

A very common task for a programmer is to open a file. This seems to be a trivial operation, and we don’t think twice about it. But what is really happening when we’re opening that file ?

## A simple C program

For this exercise, I’m going to use this very simple C program:

<script src="https://gist.github.com/franckcuny/d208c34a0b8397f3e4ca.js"></script>

The code does the following things:

* opens a file in read-only mode
* checks that we got a file descriptor
* if we don’t have the file descriptor, we print an error and exit
* we close the file descriptor
* we exit

This is really simple and not much is going on, right ? Let’s take a better look at it.

The `fopen()` function that we use is provided by the libc. It's documentation is pretty straight forward (`man 3 fopen`): *"The fopen() function opens the file whose name is the string pointed to by path and associates a stream with it."*.

## Run the program

We’re going to compile the source code first, so we can run the program:

```bash
gcc -o test test.c
```

## Overview

First I want to have an overview of the execution of this program. For this we will use `strace`.

<script src="https://gist.github.com/franckcuny/7b9b9ab4fdccab364674.js"></script>

We can ignore most of that output, only the last few lines interest us. We can see two functions related to the code we wrote:

* a call to open, with **/etc/issue** as the first argument
* a call to close, again, with 3 as the first argument

The first function is the system call `open()`, and we see that it returns 3, which is our file descriptor. When `close()` is called, it's only argument is again 3, which is the file descriptor returned by `open()`, and then we exit.

## Deeper

Now let’s invoke the program with gdb:

<script src="https://gist.github.com/franckcuny/5ab16ac3a075200aafa1.js"></script>

We can see the calls (the `callq` instructions) to our three functions: `fopen()`, `perror()` and `fclose()`, but we want to take a look at what exactly is behind this functions. Let's try to dig the `fopen` instruction a little bit more (I've removed all the lines that are not the `callq` instructions):

<script src="https://gist.github.com/franckcuny/1d7883696306611e9bd3.js"></script>

OK, so here we can see that we’re calling the function `_IO_new_file_fopen()`.

## libc

In our program, we're using functions provided by the libc. We're going to take a look at `_IO_new_file_fopen`, and we can read the source [here](http://fxr.watson.org/fxr/source/libio/fileops.c?v=GLIBC27#L252).

Most of the function is to set a bunch of flags, and then the next call we’re interested in is [`_IO_file_open`](http://fxr.watson.org/fxr/source/libio/fileops.c?v=GLIBC27#L335). The function is defined [here](http://fxr.watson.org/fxr/source/libio/fileops.c?v=GLIBC27#L217). As you can see, here we end up calling `open()`.

## system call

The `open()` function is one of the linux system calls. If we look at [the list of syscalls](http://lxr.free-electrons.com/source/include/linux/syscalls.h), we can see that it is mapped to [`sys_open`](http://lxr.free-electrons.com/source/include/linux/syscalls.h#L512).

The function is defined in [fs/open.c](http://lxr.free-electrons.com/source/fs/open.c#L992), and do a call to [do_sys_open](http://lxr.free-electrons.com/source/fs/open.c#L964).

The interesting part of the function starts with the call to `get_unused_fd_flags()`, where we get a file descriptor. Then we do the call to `do_filp_open()`, where we end up (via more functions call):

* geetting a file struct
* find the inode
* populate the file struct

To finish, we do a call to `fsnotify()`, which will notify the watchers on this file, and add the file descriptor with the other struct files.

## inodes

To open a file, you need to locate it on the disk. A file is associated with an inode, which contains meta data about your file, and they are stored on your disk. When you want to reach a file, the kernel will find the inode and from that the location on the disk. You can read more about inodes on [wikipedia](https://en.wikipedia.org/wiki/Inode), and this [great page about ext4](https://ext4.wiki.kernel.org/index.php/Ext4_Disk_Layout).

You can run `man 1 stat` in your shell on the file to see the information we can find.

<script src="https://gist.github.com/franckcuny/0104bdea0e515f809ad4.js"></script>

An inode is a data structure to represent an object on the filesystem.  If you look at the previous output, you can see information like the size, the number of blocks, how many references exists to this file (links), etc.

Here, we can see that the inode is 679618. Now let’s take a look with the FS debugger:

<script src="https://gist.github.com/franckcuny/016e6fc5be47a1fd4b4b.js"></script>

There's many cools things you can do with inode, like using `man 1 find` to find a file based on it's inode instead of file name.

## Deeper!

Valgrind is another amazing tool to do analysis of a program. Let's recompile our binary with the `-g` option, to embed debugging information in our binary:

```bash
gcc -g -o test test.c
```

`valgrind` has an option `--tool` to use specific tool. Let's run valgrind with the **callgrind** tool, followed by `callgrind_annotate` to get a more readable output:

<script src="https://gist.github.com/franckcuny/313fb41e150dfb28a2f7.js"></script>

With the `--cache-sim=yes` option, we count all the instructions for read access, cache misses, etc. Another nifty tool is **cachegrind**, which shows the cache misses for different level of caches.

<script src="https://gist.github.com/franckcuny/71c1ae266b26aa8bf6e1.js"></script>

## The end

As you can see, using various tools (and there's more tools available!), you can see that opening a file involves a lot of operations behind the scene.
