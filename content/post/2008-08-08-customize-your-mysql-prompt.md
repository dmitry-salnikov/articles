---
date: 2008-08-08T00:00:00Z
summary: In which we customize our MySQL prompt
title: Customize your MySQL prompt
---

To customize your MySQL prompt, create a .my.cnf file in your $HOME then add the following:

```sh
[mysql]
prompt="\\u [\\d] >"
```

Your prompt will now looks like this: `username [dabatases_name] >`
