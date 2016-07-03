---
date: 2009-02-17T00:00:00Z
summary: In which we tidify a JSON in vim.
title: tidify a json in vim
---

If you have to edit json files from vim, you may want to make them more readable, here is how you can do this:

start by installing the JSON::XS perl module from the CPAN by running `sudo cpan JSON::XS`, then, edit your .vimrc and add the following

```vim
map <leader>jt  <Esc>:%!json_xs -f json -t json-pretty<CR>
```

now while editing a json file, you can hit `,jt` (or whatever your leader is set to) and tidify a json.
