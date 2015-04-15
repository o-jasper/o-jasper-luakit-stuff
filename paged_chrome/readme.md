
*NOTE* it is likely better to try emulate an existing lua server system,
assuming one of them is well-thought out and has ajax or some such.
(i'd expect so)

Two ways to define a page, the template-based one is better IMO, the former
is "closer to what happens".

## Paged chrome.
`paged_chrome.paged_chrome(chrome_name, pages)` adds a chrome page, pages
are stored at `paged_chrome_dict[]`, you can add more afterward.

`pages.default_name` indicated a default page. Other ones are pages themselves;

`page.html(view, meta)` should return the html of the page.

`page.init(view, meta)` initialized the page.

Here, `view`, `meta` are given as `chrome.add` has them in there. Likely it
will just register javascript-accessible functions here.

## Defining by template
Define these in an object, and then use `templated_page(page)` to turn it into the
above;

`page.to_js` dictionary of lua functions you want it to be able to use.

`page.repl_list` dictionary of values to replace in a template

`page.repl_pattern` is the template itself, *however*, advised to instead
create the file `"assets/{%page_name}.html"`, where a variant looks.

**TODO** actually looks at `listview/assets/`

## Other

`paged_chrome.asset(what,kind)` uses the `o_jasper_common` `load_asset`, but looks in
the local `"assets/"` directory and `kind` is defaultly `.html`.
