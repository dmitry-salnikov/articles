If you have to edit json files from vim, you may want to make them more readable, here is how you can do this:

start by installing the JSON::XS perl module from the CPAN by running `sudo cpan JSON::XS`, then, edit your .vimrc and add the following

``` viml
map <leader>jt  <Esc>:%!json_xs -f json -t json-pretty<CR>
```

now while editing a json file, you can hit `,jt` (or whatever your leader is set to) and tidify a json.
