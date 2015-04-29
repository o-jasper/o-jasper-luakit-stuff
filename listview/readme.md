# List view lib / messages lib

Intention to make a fairly general messages/list view lib.

To be applied to... well whatever might use SQL to store data.
In the sub directories, there are some uses.

## Search
Search terms are anded. Explicit strings `""` are taken as whole.
`keyword:...` uses the below keyword. That may also have a space inbetween
or utilize an explicit strings. Search is not well-tested yet, and intended
as user-interface.

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

These are entirely redefinable.

In the future there might be a second input with default additions to the
search. For instance `-tags:hide` to hide things defaultly.

## TODO

* Combine multiple tables?

* Document better.

* "Stored search/sql-appends" so that users can create different topics.

* Put the search term in the address bar, or at least possibly, 
  so people can link to their searches...
  
  However a malicious link can mess with the SQL database. Perhaps alternatively
  just have the hash of a search stored somewhere, connected to the search.
  Or perhaps possible to only allow it manually.
  
  Add a command to search in the history.

* (Optional)continuous scrolling, and other things to make looking at results
  nicer. (keywords in the search should override? indicate that it is overridden?)
  Possibly instead of "Next 20", "20 more".

* Selecting multiple in one click with shift.

* Get sensible location of selection immediately the main search.

* Using keys to navigate gui.
