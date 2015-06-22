
Takes a SQL table description and makes it able to handle search-terms.

You can add things like `tags:` and it'll understand. This is extensible
aswel.

# Usage

You need `local c = require "o_jasper_common"` available.

`require "sql_help"` has `SqlHelp` and `SqlEntry`, intended to be added as
metatables. One helps you with an sql table, the other adds functionality to
returned entries for convenience. (TODO describe how i do metatables better)

The `.values` of both the entry and help describe the thing being searched on.
Here:

* `table_name`: the table name being searched.
* `taggings`: the table name *of the tags*.(optional)
* `tagname`: what the tag column is named in the taggings. Suggest `"tag"`
* `row_names`: TODO rename to column name.. silly. The names of all the entries.
* `idname`: primary ID.
* `textlike`: columns "searched as text".
* `time`: column acting as time. `timemul` is factor to add to make it milliseconds.
  (so if time is seconds, `1000`)
* `order_by`: thing to defaultly order by. (currently really kindah only option.)
* `string_els`: elements that are strings.
* `int_els`: elements that are integers.

So do:

    YourEntry = c.copy_meta(sql_help.SqlEntry)
    ... add your stuff ... 
    YourEntry = c.metatable_of(YourEntry)
    
    YourHelp = c.copy_meta(sql_help.SqlHelp)
    YourHelp.values = YourEntry.values
    ... add your stuff ...
    YourHelp = c.metatable_of(mod_YourHelp)
    
Basically this is just some class derivation, where you change some values.

Setting `entry_meta` in the latter is so the correct entry is given to the return
values. Alternatively you can change `entry_fun(self, data)` instead.

The `.db` value is the database itself. It is not needed for all the functions.
because then "how i do it is always the same")

After that, you should be able to make an instance
`helper = setmetatable({db=yourdb}, YourHelp)`, or you could put the `db` into
the metatable instead.

### Searching/query creation.

The object is *stateful*; basically, for a query, you make a copy;
(of course, here the metatable is not copied)
`h = helper:new_SqlHelp()` then put in information in about the search
you want to do, and then at the end use `h:result()` to get the resulting list.
(with entry metatables, `h:raw_result()` for without) Or `help:sql_code()` to
get the SQL code for it, or `help:sql_pattern()` to get the pattern 
*with values not filled in*.

The main useful function is the search; `h:search(search_string)`, where
`search_string` based on a user-facing-like search string.

There are other functions that `search` will use, but can be used directly,
like `h:tags(list_of_tags)`, `h:not_tags(list_of_tags)` or
less then; `h:lt(column, value)`, `gt` greater then, `:after(time)`,
`:before(time)`, `like(string, column)`, `not_like(string, column)`,
`:text_like(search, negate)`

And there are other things to do, for instance with `h:order_by(what, way)`, you can
add ordering. (`way` defaultly descending, `"ASC"` will make that ascending)

`h:limit(from, count)` sets limitations.

#### Search customization
`.searchinfo.matchable` controls what it looks for, and in what order,
and `.searchinfo.match_funs` is the funcions to them use.

For instance `"tags:"` would find `tags:a,b,c`, and then call:

    .searchinfo.match_funs(self, state, "tags:", "a,b,c")
    
Where `self` is the entire object, and `state` allows you to remember stuff between tags.

There is a whole bunch defaultly.

### Other
There is also some stuff to `helper:enter(entry)`
`helper:update(entry)`, `helper:update_or_entry(entry)` 
these will also do tags, `entry.tags` being expected to be a list of them.

Aswel as `helper:delete_id(id)`, `helper:get_id(id)`.

There is the info-function facility. Basically, having a function put
indicate importants of information it is giving, and sorting it.
Listview later-on uses added `paged_chrome` functions to write html
based on that too.

#### Note
Rthe `metatable_of` and `copy_meta` are for future ability to make sure
that the metatables are only alterable when desired. Admittedly, the whole
metatable thing.. It is awesome to be so in control, but, not enough
guidance on how to do it. (What i use is real simple though!)

### Examples
For examples, see the (non-chrome-parts-of) listview.history, or 
listview.oldBookmarks, which do fairly simple modifications.

# Todo

* Search multiple tables at the same time.

* Make it usable separately aswel
  (as a user-search thing, not for programmatic use you expect to be stable)
  + standalone lua + sql + thislib
  + then commandline thing.

* Figure out security. Do the question marks mean data will stay data, and
  not be interpreted as SQL. Sanitizing?

* Take some stuff out from the above text and put in an API text instead.
  (here will be an introductionary/most-important-aspects text.

* Perhaps `SqlHelp` is starting to do a lot. Split off the search and
  "builtins" portions?
