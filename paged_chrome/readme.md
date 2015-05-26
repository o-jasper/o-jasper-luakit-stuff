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

## Defining by template
It is advised to use this interface, and then use `templated_page(page)`
to turn it into the object below.

`page.to_js` dictionary of lua functions you want it to be able to use.

`page.repl_list(args, view)` dictionary of values to replace in a template.

`page.repl_pattern` is the template itself, just as a value. Can instead
create the file `"assets/{%page_name}.html"`, where it looks alternatively.

## Paged chrome.
This is the actual interface that is used, as said, the above is turned
into this one via `templated_page(page)`

`paged_chrome.paged_chrome(chrome_name, pages)` adds a chrome page, pages
are stored at `paged_chrome_dict[]`, you can add more afterward.

`pages.default_name` indicates a default page. Other ones are pages themselves;

`page.html(args, view)` should return the html of the page.

`page.init(args, view)` initialized the page.

## Example:
`example/init.lua` shows how to use both of the above.

## TODO

* Make the template-based one usable as a server. (ajax-like bindings)
