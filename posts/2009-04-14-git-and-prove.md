A little trick to force you to run your tests before a commit:

in a repositorie, create the following file **.git/hooks/pre-commit** with this content:

``` bash
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
