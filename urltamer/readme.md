# Taming the urls that are accessed
Blocks, redirect, logs by random functions you define based on information
available.

**Status** seems to work.. okey, but over-blocks, and probably under-blocks
too.

## Specifying how to treat uris

TODO

### The `info` object

`info.uri`, `info.domain` are the uri, domain *of the request*.

`info.vuri`, `info.from_domain`, are the uri, *of the window*, i.e. of the
originating page.

`info.current_status` returns
`{status:status, times:{..times that it was different statusses..}}`
These are currently recorded based on the signals
[load-status](http://webkitgtk.org/reference/webkitgtk/stable/webkitgtk-webkitwebview.html#WebKitWebView--load-status),
[navigation-request](http://webkitgtk.org/reference/webkitgtk/stable/webkitgtk-webkitwebview.html#WebKitWebView-navigation-requested).

`info.status == info.current_status.status`

`info.from_time` is the time of the last statusses change implying user interaction.
Currently, only the signal navigation-request is used.
For instance the urlcmd `block_late` uses this to shut a website
up if, so it cannot talk home after some time. (this might cause behavior to differ
depending on load times)

`info.dt` is a convenience for the time since. **TODO** do it for other ones. 

`info:own_domain()` returns whether the request is from the same domain as the 
originating page. `info:uri_match(match)` returns true if any from a
lua-regex(list) match.

### The result `result`
You can do what you want with `result`, only `result.redirect` contains a string
if you want to redirect. It has to be allowed to do that.

## TODO
  
* Storing config in SQL and an interface to quickly configure.

* Make stuff for this:
  + Adding rules based on user interaction with the pages.
    
    Regex golf?
  + Addblock integration.
  + Handles Cookies? Javascript?
  + Proxying?

* Have a system of reasons. I.e. `result.allow = {"blacklist", "late"}`,
  and then later, something might "excuse" *particular* reasons.
  (or fail to excuse)
  
  Or some other way to keep the overview.
