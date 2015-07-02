# Mirroring sites
Mirrors sites locally by different methods.

A mirrorer derives from `base.lua` and has the extra method
`:do_uri(uri, clobber, window)` it should return the path
where the main file was put, or a key-value uri-to_path.

`cmd_from_mirror.lua` is a function that turns `cmd/` contains
examples.

### Currently have
* `js_simple.lua` basically a `:dump`, uses 
  `window.view:eval_js("document.documentElement.outerHTML")` 
  to get at the html state when viewing.
* `js_readhtml.lua` uses the same to get the html, but then finds all the `style`,
  `script` and `img` tags, using wget to get the `src`-es local, and changing the
  `src` tag to that local file.
* wget version, actually not sure if the files are going the right way! 

### TODO
* Sql-table keeping track of it a bit more. Listview incorporation.

* Not well tested/tried

