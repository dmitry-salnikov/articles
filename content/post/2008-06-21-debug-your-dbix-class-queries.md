---
date: 2008-06-21T00:00:00Z
summary: In which I explain how to see SQL queries generated for DBIx::Class.
title: debug your DBIx::Class queries
---

If you use DBIx::Class and want to see what the SQL generated looks like, you can set the environment variable **DBIC_TRACE**.

```sh
% DBIC_TRACE=1 my_programme.pl
```

And all the SQL will be printed on **STDERR**.

If you give a filename to the variable, like this

```sh
% DBIC_TRACE="1=/tmp/sql.debug"
```

all the statements will be printed in this file.
