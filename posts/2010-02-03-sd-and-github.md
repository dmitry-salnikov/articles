If you are using the version of SD hosted on GitHub, you can now clone and pull issues very easily. First,

``` bash
git config --global github.user franckcuny
git config --global github.token myapitoken
```

This will set in your .gitconfig your github username and api token. Now, when you clone or pull some issues using sd:

``` bash
git sd clone --from github:sukria/Dancer
```

sd will check your .gitconfig to find your credentials.
