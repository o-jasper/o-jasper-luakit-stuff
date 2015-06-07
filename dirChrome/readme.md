# Directory viewer

## Info functions
It is possible to return "info functions" in `globals.dirChrome.infofuns`
these take the path and `Dir` object as input and return an info object, or
`nil`.(indicating that the info function is not about that.

Info objects have;

`InfoMeta.maybe_new(path, file)` creates a new one, *if*
the infofun applies.

`.path`, `.file` gets the path, file back.

`info:priority()` returning how important it is.
It may be sorted by importance. `> 0` is defaultly shown.
`config.infofun.priority_override` can override it.

Anything main selection shows ontop.

`info:html(asset_function)` return the html to be shown. Returning `nil`,
it will not show anything. (you might want to indicate a reason.)
`asset_function` is a function to which you feed files, and it'll
return that asset as normally.

(TODO) `info:to_js()` export functions to js.

# TODO

* Have more order-by options. Probably want:(at least)
  + Modify date (current)
  + Size.
  + Alphabetically.

* Infofuns get the same object at the list-thingy does..
  
  + `html_calc` has to go on the entry object, and unify the file
    infoview with that.

* More infofuns, and a way to have a "mode" of viewing and different
  infofuns apply depending on the mode.
  
* Deal with it when files/directories may not be accessed.

* (optionally, defaultly)Hide dot files
