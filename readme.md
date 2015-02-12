# Log in using `pass`

Uses javascript to search for the login form, then it searches using
`pass ls domain` where it uses the first element to
`pass show domain/account`, or prefers one provided in
`globals.search_login.account_default[domain]`.

[Pass page](http://www.passwordstore.org/).

### (a way of)Installation
Symlink it from `~/.config/luakit/`, add `require "luakit_search_logon"` in
`~/.config/luakit/rc.lua`. Add bindings if desired.

### More configs
`globals.search_login.executable` and `...pass_args` tell what program is used
and arguments to be applied to everything.

`globals.search_login.pass_pre_domain` is prepended to accesses `pass`,
so you can organize that if you want to.

### Potential improvement

* The search for the input forms is might not be sure to succeed. It does
  have the option of you-pre-filling in the name, and selecting the password
  form manually.
  
  Misreading it could mean accidentally sending the password the wrong place.
  It only searches forms on the same domain, but.. maybe some ad or some shit
  can insert shit into the page? (I dunno) If it doesnt get a password, it
  will just fill in a login.
  
  Github doesnt seem to have the login form on every page.

* Doesnt look like `pass ls ..` stdout is meant for use? Probably fine, but
  could be safer.

* Suppose a chrome page wouldnt hurt. (But probably not terribly useful either)

* Are these passwords floating in memory now a bit? Improvable?

* Not very tested. Make issues if you encounter a bug.

### Other
Heavily inspired on Matthias Beyers
[pass2luakit](https://github.com/matthiasbeyer/pass2luakit).

Released under the GPLv3.
