# Log in using `pass`

This one is not really good enough yet because the search does not find the
login form decently.

Uses javascript to search for the login form, then it searches using
`pass ls domain` where it uses the first element to
`pass show domain/account`, or prefers one provided in
`globals.search_login.account_default[domain]`.

[Pass page](http://www.passwordstore.org/).

### (a way of)Installation
Symlink the `search_login/` directory from `~/.config/luakit/`, 
add `require "search_logon"` in `~/.config/luakit/rc.lua`.
Add bindings if desired.

### More configs
`globals.search_login.executable` and `...pass_args` tell what program is used
and arguments to be applied to everything.

`globals.search_login.pass_pre_domain` is prepended to accesses `pass`,
so you can organize that if you want to.

### Potential improvement

* [Depends on this pull request](https://github.com/mason-larobina/luakit/pull/269)
  If that is pulled you can probably ignore this point.
  
  Either get the relevant changes from that branch(`lib/lousy/init.lua` and 
  `lib/lousy/load_asset.lua`), or you can
  [change `local js = ..``](https://github.com/o-jasper/o-jasper-luakit-stuff/blob/master/search_login/init.lua#L39) to be a string with the contents of the `enter_pw.js` file.

* **The search for the input forms does not succeed sufficiently**. It does
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
