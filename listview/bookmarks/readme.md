# Bookmarks
Using listview,(and all its search functions) and with added data-uris.

## Installing
Needs access to the same directories as listviewHistory,
otherwise, in `~/.config/luakit/rc.lua`, do
`require listview.bookmarks.chrome"`.

## TODO

* Gui able to *change* bookmarks. (rather than just add)

* Importing bookmarks from existing system. (that are not in there yet)

* Bindings for adding bookmarks.

  + I dont *quite* like how the existing bookmarks "goes to its page"
    to fill in data.. Maybe we need split-screen so you can do it,
    and then un-split the screen, or something.

* Way to add functions to automatically assign data-uris.
  + A way to look at files behind data URIs. Like a longer description.

* Make a more elaborate history, that looks at other info too. In this
  case, whether bookmarked.

* Want a way help people "characterize" things for their own memory?
  
  Perhaps "not for" bookmarks though!

* Way to browse the old bookmarks system aswel, better importing
  functions. (although simple is fine)
