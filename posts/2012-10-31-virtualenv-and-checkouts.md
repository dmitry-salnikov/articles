I've started to do some Clojure in my spare time. The default tool adopted by the community to manage projects is [leiningen](http://leiningen.org). For those of you who don't know what `lein` is, it's a tool to automate your Clojure project: it will boostrap a new project, install the dependencies, and there's a plugin mechanism to extend the default possibilities of the tool.

One of the nice feature of the tool is the **checkouts** directory. From the [FAQ](https://github.com/technomancy/leiningen/blob/preview/doc/FAQ.md):

> If you create a directory named checkouts in your project root and symlink some other project roots into it, Leiningen will allow you to hack on them in parallel.

For Python projects at [$work](http://www.saymedia.com/careers) I use [virtualenvwrapper](http://virtualenvwrapper.readthedocs.org/en/latest/) to easily work on them without having to deal with conflicting dependencies. When I need to change a library that is used by one of the project, usually I go to the virtualenv directory and create a symlink so it uses the one I'm editing.

What I really want is a mechanism similar to `lein`, where I can have a **checkouts/** directory inside the main project, where I can clone a library or create a symlink. Since `virtualenvwrapper` provides a hook mechanism, I wrote a small hook inside **~/.virtualenvs/postactivate**:

``` bash
    #!/bin/bash

    # move to the directory of the project
    proj_name=$(echo $VIRTUAL_ENV|awk -F'/' '{print $NF}')
    proj_path=/home/vagrant/src/$proj_name

    cd $proj_path

    if [ -d checkouts ]; then
        for ext in $(ls checkouts); do
            export PYTHONPATH=proj_path/checkouts/$ext:$PYTHONPATH
        done
    fi
```

Then, when I type `workon $project_name` in my shell, the environment is activated, I'm moved to the right directory, and the library inside the **checkouts/** directory are added to my **PYTHONPATH**.
