# Taming the urls that are accessed
Blocks, redirect, logs by random functions you define based on information
available.

**Status** seems to work.. okey, but over-blocks, and probably under-blocks
too.

## Specifying how to treat uris

TODO

## `responder[domain].resource_request_starting = function(info, result) ... end`
it overrides the above. The `result`/`info` is the same as the above system uses.

The return value is a pair, the `allow, result`. It is not advised because it
needs defining a lot of times. Besides the only advantage of this compared to
doing it entirely DIY below is the`info` and `result` object helping you out,
logging for you.

    view:add_signal("resource-request-starting", function (v, uri) ..stuff.. end)

## Disabling entirely
`responder[domain].impervious` being non `false`/`nil` allows everything.

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

`result.remarks` are used for logging. **TODO** Perhaps i should add a signal
for the result.

## TODO

* Log user-specify-edly with a good default, including time-limits on keeping
  stuff.
  
  + Keep a list of stuff-blocked-for-this, and have a function where you can
    allow just-those this times. A better way that `:UrlPermissive` to get
    around overblocking.

* How `parametered_matches.lua` works is a bit too much imperative really.
  All i want is  for the data be storable in SQL in the future for easy
  configuration, and `lua` does the actual work.
  
  NOTE: probably i will just interpret the string as lua.
  (`loadstring()`)
  
* Storing config in SQL and an interface to quickly configure.

  + Allowing definition of bits-of-gui for setting parameters for
    `urlcmd`(and possibly `urlfunc`)

* Make stuff for this:
  + Adding rules based on user interaction with the pages.
    
    Regex golf?
  + Addblock integration.
  + Handles Cookies? Javascript?
  + Proxying?
