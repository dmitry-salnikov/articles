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
