
* *NOTE* it is likely better to try emulate an existing lua server system,
  assuming one of them is well-thought out and has ajax or some such.
  (i'd expect so)

Two ways to define a page, the template-based one is better IMO, the former
is "closer to what happens".

If you do not use `view`, `meta`, you have a better shot at it being able
to work as served page.

## Defining by template
It is advised to use this interface, and then use `templated_page(page)`
to turn it into the object below.

`page.to_js` dictionary of lua functions you want it to be able to use.

`page.repl_list(args)` dictionary of values to replace in a template.

`page.repl_pattern` is the template itself, just as a value. Can instead
create the file `"assets/{%page_name}.html"`, where it looks alternatively.

## Paged chrome.
`paged_chrome.paged_chrome(chrome_name, pages)` adds a chrome page, pages
are stored at `paged_chrome_dict[]`, you can add more afterward.

`pages.default_name` indicates a default page. Other ones are pages themselves;

`page.html(args, view, meta)` should return the html of the page.

`page.init(args, view, meta)` initialized the page.

Here, `view`, `meta` are given as `chrome.add` has them in there. Likely it
will just register javascript-accessible functions here.

## Other

`paged_chrome.asset(what,kind)` uses the `o_jasper_common` `load_asset`, but looks in
the local `"assets/"` directory and `kind` is defaultly `.html`.

## TODO

* The note above about being equivalent to a server is overriding.
  
  Might try hand at using Luvit and making the javascript bindings ajax-like.

* If an `page.repl_list` entry is not found, what is best option?
