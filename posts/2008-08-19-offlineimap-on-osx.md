If you are using offlineimap on leopard, on an imap connection with ssl (like GMail) and it keep crashing because of the following error:

``` bash
File "/Library/Python/2.5/site-packages/offlineimap/imaplibutil.py", line 70, in _read
return self.sslsock.read(n)
MemoryError
```

you can fix it with this fix:

``` bash
sudo vim /Library/Python/2.5/site-packages/offlineimap/imaplibutil.py +70
```

then, comment line 70 and add this line

``` python
return self.sslsock.read(min(n, 16384))
#return self.sslsock.read(n)
```

you can read a description of the bug here.
