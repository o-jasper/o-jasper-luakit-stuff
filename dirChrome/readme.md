# Directory viewer

## Info functions
It is possible to return "info functions" in `globals.dirChrome.infofuns`
these take the path and `Dir` object as input and return an info object, or
`nil`.(indicating that the info function is not about that.

Info objects have;

`InfoMeta.maybe_new(path, dirobject)` creates a new one, *if*
the infofun applies.

`.path` gets you the path back.

`info:priority()` returning how important it is.
It may be sorted by importance. `> 0` is defaultly shown.
`config.infofun.priority_override` can override it.

Anything main selection shows ontop.

`info:html()` return the html to be shown. Returning `nil`,
it will not show anything. (you might want to indicate a reason.)

(TODO) `info:to_js()` export functions to js.

# TODO

* Currently aware of current directory, *but* doesnt use it enough to show it.

  + Defaultly search for current directory exactly, and hide the search bar.

* Have more order-by options. Probably want:(at least)
  + Modify date (current)
  + Size.
  + Alphabetically.

* Way to indicate types of files as special.

  For instance `readme.md` as "text of the directory", and taking other
  `.md` files as showable.
  
* Deal with it when files/directories may not be accessed.

* (optionally, defaultly)Hide dot files
