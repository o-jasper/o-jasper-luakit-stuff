# Better history browser (imo, of course)
Does an sql search in the *existing* history table.

Uses this [general (sql)list viewer](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/listview#list-view-lib--messages-lib). check the readme there for 
what the search can do. In short, you can view the SQL command at any time,
edit and use that if you want, and it has stuff like `after:` `title:` `uri:`
etc. 
(like `site:` but that is one that happens to be missing now. Though there is
`like:`)

## Installing
Download, make sure the directories are accessible from the configuration
directory, for instance:

    cd  ~/.config/luakit/
    ln -s path_to_/o-jasper-luakit-stuff/listview
    ln -s path_to_/o-jasper-luakit-stuff/o_jasper_common
    ln -s path_to_/o-jasper-luakit-stuff/paged_chrome

It also needs the socket package.. Lua doesnt come with millisecond times.

And then in `~/.config/luakit/rc.lua`, do `require listview.history.chrome"`

Then, hopefully it works. 
Saw [sort-of a plugin system](https://github.com/mason-larobina/luakit-plugins),
should look at that.

## TODO
* More elaborate version that will take stuff together from the different
  info in the SQL db.
  
