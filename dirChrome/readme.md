# Directory viewer

## Info functions
It is possible to return "info functions" in `globals.dirChrome.infofuns`
these take the path and `Dir` object as input and return an info object, or
`nil`.(indicating that the info function is not about that.

Info objects have;

`InfoMeta.maybe_new(path, dirobject)` creates a new one, *if*
the infofun applies.

`.path`, `.file` gets the path, file back.

`info:priority()` returning how important it is.
It may be sorted by importance. `> 0` is defaultly shown.
`config.infofun.priority_override` can override it.

Anything main selection shows ontop.

`info:html()` return the html to be shown. Returning `nil`,
it will not show anything. (you might want to indicate a reason.)

(TODO) `info:to_js()` export functions to js.

# TODO

* Have more order-by options. Probably want:(at least)
  + Modify date (current)
  + Size.
  + Alphabetically.

* More infofuns, and a way to have a "mode" of viewing and different
  infofuns apply depending on the mode.
  
* Deal with it when files/directories may not be accessed.

* (optionally, defaultly)Hide dot files
