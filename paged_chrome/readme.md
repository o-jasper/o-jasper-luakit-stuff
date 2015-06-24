# Paged Chrome pages

Two ways to define a page, the template-based one is better IMO, the former
is "closer to what happens".

If you do not use `view`, and stick to `args.path` have a better shot at it being able
to work as served page.

## Installing
Make sure both `o_jasper_common` and `paged_chrome` is accessible.
For instance, by symlinking the directories.

Then just `paged_chrome = require "paged_chrome"`

# Using
`paged_chrome(chrome_name, page_table)` adds the chrome page to luakit.

The table is one of pages by directory names, except for
`page_table.default_name`,
which indicates where to redirect if the page does not exist.

## Single page;
This is the "raw" interface, it is better to use the templated one.

`page.name` *must* the be name.

`page:html(state)` should return the html body of the page.
`state.conf` contains configurations.

`page:on_first_visual(state)` is used on that signal. If not defined,
anything in `page:to_js` is bound to javascript.

## Suggested templated page
If the above do not exist, it tries instead to make things work with
`require "paged_chrome.Suggest"`. You could instead put that in your metatable.

It instead has the requirements:

`.name` simply remains a requirement.

`.to_js` field or `:to_js(args)` method, giving a table of functions to
bind tojavascript.

`.where` field indicating where to look for assets. Used to create
`:asset(file)` for you. This will also imply how to find the first template,
and fill in parts of the template referring to files. (`:repl` takes precidence)

`:repl(state)` returning a table that is used to replace things in the template.

## Example:
`example/init.lua` shows how to use both of the above.

## TODO

* When template-like, usable as server.

* Perhaps being able to make one page with a lot of embedded other pages
  could be nice.
  
  Perhaps some kind of frame thing. Certainly getting everything to work past
  each other(js bindings, js,css definitions, ids..)
  would be tricky and complex.
