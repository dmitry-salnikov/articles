---
layout: post
title: On opening a file
summary: In which I try to understand what happens when you open a file
---

A very common task for a programmer is to open a file. This seems to be a trivial operation, and we don’t think twice about it. But what is really happening when we’re opening that file ?

## A simple C program

For this exercise, I’m going to use this very simple C program:

```c
#include <stdio.h>

int main() {
  FILE *fh;

  if ((fh = fopen("/etc/issue", "r")) == NULL) {
    perror("fopen");
    return 1;
  }

  fclose(fh);
  return 0;
}
```

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

```bash
$ strace ./test
execve("./test", ["./test"], [/* 31 vars */]) = 0
brk(0)                                  = 0x25e0000
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f7f97a24000
access("/etc/ld.so.preload", R_OK)      = -1 ENOENT (No such file or directory)
open("/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
fstat(3, {st_mode=S_IFREG|0644, st_size=33297, ...}) = 0
mmap(NULL, 33297, PROT_READ, MAP_PRIVATE, 3, 0) = 0x7f7f97a1b000
close(3)                                = 0
access("/etc/ld.so.nohwcap", F_OK)      = -1 ENOENT (No such file or directory)
open("/lib/x86_64-linux-gnu/libc.so.6", O_RDONLY|O_CLOEXEC) = 3
read(3, "\177ELF\2\1\1\0\0\0\0\0\0\0\0\0\3\0>\0\1\0\0\0\320\37\2\0\0\0\0\0"..., 832) = 832
fstat(3, {st_mode=S_IFREG|0755, st_size=1845024, ...}) = 0
mmap(NULL, 3953344, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7f7f9743e000
mprotect(0x7f7f975f9000, 2097152, PROT_NONE) = 0
mmap(0x7f7f977f9000, 24576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x1bb000) = 0x7f7f977f9000
mmap(0x7f7f977ff000, 17088, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f7f977ff000
close(3)                                = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f7f97a1a000
mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f7f97a18000
arch_prctl(ARCH_SET_FS, 0x7f7f97a18740) = 0
mprotect(0x7f7f977f9000, 16384, PROT_READ) = 0
mprotect(0x600000, 4096, PROT_READ)     = 0
mprotect(0x7f7f97a26000, 4096, PROT_READ) = 0
munmap(0x7f7f97a1b000, 33297)           = 0
brk(0)                                  = 0x25e0000
brk(0x2601000)                          = 0x2601000
open("/etc/issue", O_RDONLY)            = 3
close(3)                                = 0
exit_group(0)                           = ?
+++ exited with 0 +++
```

We can ignore most of that output, only the last few lines interest us. We can see two functions related to the code we wrote:

* a call to open, with **/etc/issue** as the first argument
* a call to close, again, with 3 as the first argument

The first function is the system call `open()`, and we see that it returns 3, which is our file descriptor. When `close()` is called, it's only argument is again 3, which is the file descriptor returned by `open()`, and then we exit.

## Deeper

Now let’s invoke the program with gdb:

```bash
$ gdb ./test
Reading symbols from ./test...done.
(gdb) break main
Breakpoint 1 at 0x4005c1
(gdb) run
Starting program: /home/fcuny/workspace/tmp/file/test

Breakpoint 1, 0x00000000004005c1 in main ()
(gdb) disassemble
Dump of assembler code for function main:
   0x00000000004005bd <+0>:     push   %rbp
   0x00000000004005be <+1>:     mov    %rsp,%rbp
=> 0x00000000004005c1 <+4>:     sub    $0x10,%rsp
   0x00000000004005c5 <+8>:     mov    $0x400694,%esi
   0x00000000004005ca <+13>:    mov    $0x400696,%edi
   0x00000000004005cf <+18>:    callq  0x4004b0 <fopen@plt>
   0x00000000004005d4 <+23>:    mov    %rax,-0x8(%rbp)
   0x00000000004005d8 <+27>:    cmpq   $0x0,-0x8(%rbp)
   0x00000000004005dd <+32>:    jne    0x4005f0 <main+51>
   0x00000000004005df <+34>:    mov    $0x4006a1,%edi
   0x00000000004005e4 <+39>:    callq  0x4004c0 <perror@plt>
   0x00000000004005e9 <+44>:    mov    $0x1,%eax
   0x00000000004005ee <+49>:    jmp    0x400601 <main+68>
   0x00000000004005f0 <+51>:    mov    -0x8(%rbp),%rax
   0x00000000004005f4 <+55>:    mov    %rax,%rdi
   0x00000000004005f7 <+58>:    callq  0x400480 <fclose@plt>
   0x00000000004005fc <+63>:    mov    $0x0,%eax
   0x0000000000400601 <+68>:    leaveq
   0x0000000000400602 <+69>:    retq
End of assembler dump.
```

We can see the calls (the `callq` instructions) to our three functions: `fopen()`, `perror()` and `fclose()`, but we want to take a look at what exactly is behind this functions. Let's try to dig the `fopen` instruction a little bit more (I've removed all the lines that are not the `callq` instructions):

```bash
(gdb) disassemble fopen
Dump of assembler code for function _IO_new_fopen:
   0x00007ffff7a82f65 <+5>:     jmpq   0x7ffff7a82eb0 <__fopen_internal>
End of assembler dump.
(gdb) disassemble __fopen_internal
Dump of assembler code for function __fopen_internal:
   0x00007ffff7a82ec8 <+24>:    callq  0x7ffff7a33410 <memalign@plt>
   0x00007ffff7a82ef8 <+72>:    callq  0x7ffff7a90760 <_IO_no_init>
   0x00007ffff7a82f0e <+94>:    callq  0x7ffff7a8e640 <_IO_new_file_init>
   0x00007ffff7a82f1f <+111>:   callq  0x7ffff7a8e920 <_IO_new_file_fopen>
   0x00007ffff7a82f40 <+144>:   callq  0x7ffff7a8f510 <__GI__IO_un_link>
   0x00007ffff7a82f48 <+152>:   callq  0x7ffff7a33470 <free@plt+48>
End of assembler dump.
```

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

```bash
$ stat /etc/issue
  File: ‘/etc/issue’
  Size: 26              Blocks: 8          IO Block: 4096   regular file
Device: fd01h/64769d    Inode: 679618      Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2014-11-16 20:04:27.655399999 -0800
Modify: 2014-07-22 08:33:52.000000000 -0700
Change: 2014-07-25 08:02:10.698239112 -0700
 Birth: -
```

An inode is a data structure to represent an object on the filesystem.  If you look at the previous output, you can see information like the size, the number of blocks, how many references exists to this file (links), etc.

Here, we can see that the inode is 679618. Now let’s take a look with the FS debugger:

```bash
$ sudo debugfs /dev/vda1
debugfs 1.42.9 (4-Feb-2014)

debugfs:  ncheck 679618 # check that the path is correct for that inode
Inode   Pathname
679618  /etc/issue

debugfs: stat <679618> # display information for that inode
Inode: 679618   Type: regular    Mode:  0644   Flags: 0x80000
Generation: 2438138670    Version: 0x00000000:00000001
User:     0   Group:     0   Size: 26
File ACL: 0    Directory ACL: 0
Links: 1   Blockcount: 8
Fragment:  Address: 0    Number: 0    Size: 0
 ctime: 0x53d27172:a6792220 -- Fri Jul 25 08:02:10 2014
 atime: 0x546973cb:9c4270fc -- Sun Nov 16 20:04:27 2014
 mtime: 0x53ce8460:00000000 -- Tue Jul 22 08:33:52 2014
crtime: 0x53d27168:18602e20 -- Fri Jul 25 08:02:00 2014
Size of extra inode fields: 28
EXTENTS:
(0):4822488

debugfs: imap <679618> # location of the inode
Inode 679618 is part of block group 82
        located at block 2622988, offset 0x0100
```

There's many cools things you can do with inode, like using `man 1 find` to find a file based on it's inode instead of file name.

## Deeper!

Valgrind is another amazing tool to do analysis of a program. Let's recompile our binary with the `-g` option, to embed debugging information in our binary:

```bash
gcc -g -o test test.c
```

`valgrind` has an option `--tool` to use specific tool. Let's run valgrind with the **callgrind** tool, followed by `callgrind_annotate` to get a more readable output:

```bash
$ valgrind --tool=callgrind --simulate-cache=yes ./test
$ callgrind_annotate --auto=yes callgrind.out.11015 test.c
--------------------------------------------------------------------------------
-- User-annotated source: test.c
--------------------------------------------------------------------------------
Ir Dr Dw I1mr D1mr D1mw ILmr DLmr DLmw

 .  .  .    .    .    .    .    .    .  #include <stdio.h>
 .  .  .    .    .    .    .    .    .
 3  0  1    1    0    0    1    .    .  int main() {
 .  .  .    .    .    .    .    .    .    FILE *fh;
 .  .  .    .    .    .    .    .    .
11  4  4    .    .    .    .    .    .    if ((fh = fopen("/etc/issue", "r")) == NULL) {
59,650 14,454 661  107 1,079   49  106  868   42  => /build/buildd/eglibc-2.19/libio/iofopen.c:fopen@@GLIBC_2.2.5 (1x)
752 240 101    0    5    0    0    4    .  => /build/buildd/eglibc-2.19/elf/../sysdeps/x86_64/dl-trampoline.S:_dl_runtime_resolve (1x)
 .  .  .    .    .    .    .    .    .      perror("fopen");
 .  .  .    .    .    .    .    .    .      return 1;
 .  .  .    .    .    .    .    .    .    }
 .  .  .    .    .    .    .    .    .
 8  4  3    0    1    .    .    .    .    fclose(fh);
791 246 101    0   43    7    0    2    .  => /build/buildd/eglibc-2.19/elf/../sysdeps/x86_64/dl-trampoline.S:_dl_runtime_resolve (1x)
1,142 349 185   50   16    0   50    .    .  => /build/buildd/eglibc-2.19/libio/iofclose.c:fclose@@GLIBC_2.2.5 (1x)
 1  .  .    .    .    .    .    .    .    return 0;
 2  2  0    0    1    .    .    .    .  }
```

With the `--cache-sim=yes` option, we count all the instructions for read access, cache misses, etc. Another nifty tool is **cachegrind**, which shows the cache misses for different level of caches.

```bash
$ valgrind --tool=cachegrind ./test
==11710== Cachegrind, a cache and branch-prediction profiler
==11710== Copyright (C) 2002-2013, and GNU GPL'd, by Nicholas Nethercote et al.
==11710== Using Valgrind-3.10.0.SVN and LibVEX; rerun with -h for copyright info
==11710== Command: ./test
==11710==
--11710-- warning: L3 cache found, using its data for the LL simulation.
--11710-- warning: pretending that LL cache has associativity 30 instead of actual 20
==11710==
==11710== I   refs:      163,367
==11710== I1  misses:        869
==11710== LLi misses:        861
==11710== I1  miss rate:    0.53%
==11710== LLi miss rate:    0.52%
==11710==
==11710== D   refs:       54,700  (40,915 rd   + 13,785 wr)
==11710== D1  misses:      2,940  ( 2,391 rd   +    549 wr)
==11710== LLd misses:      2,406  ( 1,904 rd   +    502 wr)
==11710== D1  miss rate:     5.3% (   5.8%     +    3.9%  )
==11710== LLd miss rate:     4.3% (   4.6%     +    3.6%  )
==11710==
==11710== LL refs:         3,809  ( 3,260 rd   +    549 wr)
==11710== LL misses:       3,267  ( 2,765 rd   +    502 wr)
==11710== LL miss rate:      1.4% (   1.3%     +    3.6%  )
```

## The end

As you can see, using various tools (and there's more tools available!), you can see that opening a file involves a lot of operations behind the scene.
