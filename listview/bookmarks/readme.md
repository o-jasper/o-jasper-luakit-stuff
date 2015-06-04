# Bookmarks
Using listview,(and all its search functions) and with added data-uris.

## Installing
Needs access to the same directories as listviewHistory,
otherwise, in `~/.config/luakit/rc.lua`, do
`require listview.bookmarks.chrome"`.

## TODO

* Changing bookmarks by clicking on the part to change and interface for
  adding, similarly.

* The keybinding for adding bookmarks doesnt seem to pick up the data..
  
  Also, having a small second panel come up instead of going to a
  separate tab. (would involve `config/window.lua` and stuff)

* Way to add functions to automatically assign data-uris.
  + A way to look at files behind data URIs. Like a longer description.

* Make a more elaborate history, that looks at other info too. In this
  case, whether bookmarked.

* Add [sessman](https://github.com/IsoLinearCHiP/luakit-sessman) things
  stored-in-bookmarks with `sess_{%name}` tags indicating them.

* Add "go to uri" keyword support.. *Easiest* is to just stuff it onto
  the tags.. having a tag `gn_google` takes `:open google ...` to
  the `uri`, where `{%1}`, `{%2}`etcetera map arguments.
