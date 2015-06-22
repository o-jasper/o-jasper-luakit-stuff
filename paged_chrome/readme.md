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

## Paged chrome.
`paged_chrome.paged_chrome(chrome_name, pages)` adds a chrome page, pages
are stored at `paged_chrome_dict[]`, you can add more afterward.

`page.name` *must* the be name.

`page:html(state)` should return the html body of the page.
`state.conf` contains configurations.

`page:on_first_visual(state)` is used on that signal. If not defined,
anything in `page:to_js` is bound to javascript.

*If* `page.html` does not exist, effectively the following is used;
Can be obtained from `require "paged_chrome.pattern_html"`

    local asset = require("paged_chrome").asset
    function This:html(state)
        state.conf = state.conf or {}
        -- Pattern from the function or the asset file.
        local pat = self.repl_pattern and self:pattern(state) or
            asset(self.where, (not state.conf.whole and "body" .. "/" or "") .. self.name)

        return c.apply_subst(pat, self:repl(state))
    end

`state.view` contains the view.(if applicable)
`state.whole` indicates if also the headers and stuff.

`Page.new(args)` creates a new page.

## Example:
`example/init.lua` shows how to use both of the above.

## TODO

* When template-like, usable as server.

* Perhaps being able to make one page with a lot of embedded other pages
  could be nice.
  
  Perhaps some kind of frame thing. Certainly getting everything to work past
  each other(js bindings, js,css definitions, ids..)
  would be tricky and complex.
