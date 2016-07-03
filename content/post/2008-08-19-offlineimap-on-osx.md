---
date: 2008-08-19T00:00:00Z
summary: In which I have to patch offline imap to make it work on OS X.
title: offlineimap on osx
---

If you are using offlineimap on leopard, on an imap connection with ssl (like GMail) and it keep crashing because of the following error:

```sh
File "/Library/Python/2.5/site-packages/offlineimap/imaplibutil.py", line 70, in _read
return self.sslsock.read(n)
MemoryError
```

you can fix it with this fix:

```sh
sudo vim /Library/Python/2.5/site-packages/offlineimap/imaplibutil.py +70
```

then, comment line 70 and add this line

```python
return self.sslsock.read(min(n, 16384))
#return self.sslsock.read(n)
```

you can read a description of the bug <a href="http://bugs.python.org/issue1389051">here</a>.
