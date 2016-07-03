---
date: 2009-04-14T00:00:00Z
summary: In which I add a hook to git to run my tests.
title: Git and prove
---

A little trick to force you to run your tests before a commit:

in a repositorie, create the following file **.git/hooks/pre-commit** with this content:

```sh
#!/bin/sh
if [ -d t ]; then
    res=`prove t`
    if [ $? -gt 0 ]; then
    echo "tests fails"
    exit 1
    fi
fi
if [ -d xt ]; then
    res=`prove xt`
    if [ $? -gt 0 ]; then
    echo "tests fails"
    exit 1
    fi
fi
```

and don't forget to chmod with +x.

Now, when you will do your next commit, your test suit will be executed. If the tests fails, the commit will be rejected.
