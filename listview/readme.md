
# List view lib / messages lib

Intention to make a messages/list view lib.

Not sure if i can get the generality want to call it a list view lib.

## Search
Search terms `AND`. Explicitly strings `"..."` are taken as whole.
`keyword:...` uses the below keyword. That may also have a space inbetween
or utilize an explicit strings. Search is not well-tested yet, and intended
as user-interface. Expect that it may change. Implemented in
[sql_help.lua#L183](https://github.com/o-jasper/o-jasper-luakit-stuff/blob/master/listview/sql_help.lua#L183).

Currently the following keywords. `-` means not-that.
Note that except for `or:`, tags dont apply to other tags.

* `-` must *not* match this search term. (`\-` is to escape `-`)
* `not:` negates *all* following search terms.
* `-tags:`, `-tag:`, `tags:`, `tag:` must(not) have this tag.
* `-like:`, `-lk:`, `like:`, `lk:` (doesnt) match a raw SQL LIKE term.
* `or:` ors previous and next term. **TODO** probably does *not* work properly.
* `uri:`, `desc:`, `title:` searches those terms specifically.
* `urilike:`, 
* `before:`, `after:` after/before some time. Has a time notation. Starting
  with `a`, uses an absolute time, otherwise relative, has units `ms`, `s`, `ks`,
  `min`, `h`, `d`(=`D`), `week`(=`wk`), `M`, `Y`.
* Non-tag are just search-terms (`LIKE '%search%'`)

In the future there might be a second input with default additions to the
search. For instance `-tags:hide` to hide things defaultly.

## TODO

* Combine multiple tables? Searching them at the same time?

* Start logging stuff
