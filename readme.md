# Bunch of [luakit](http://mason-larobina.github.io/luakit/) things

* [search_login](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/search_login#log-in-using-pass), which uses `pass` and searching the html to login.
* [urltamer](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/urltamer#taming-the-urls-that-are-accessed), running code based on `uri` being accessed,
  blocking/redirecting/managing view behavior based on them.
* A [nicer history searcher](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/listview/history/).
* [nicer bookmarks](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/listview/bookmarks/), with basic importer.
* .. based on [listview](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/listview#list-view-lib--messages-lib)
  searching SQL, however, might end up just doing so over 
  logs, messages, bookmarks, history. (limited extent)

* Again based on it, a [nicer directory browser](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/dirChrome/),
  that is extensible, you can add 'info generators' that fill an html area.
  
  First one is one that adds a markdown reader for this.

Note that although it is called `o-jasper-luakit-stuff`, i dont mean that it is
just my project. Just not-clogging the namespace, and getting all the damn
things in one repo.

## Principles
In order to keep things easy for others to use/extend too, need to try
make things in a principled way. **I am not sure how to best do this yet.**

* For extension, never *require* knowledge about the metatables i am using.

  Basically, whenever the "user"(still a programmer) provides an object,
  the reference will just tell him what members that object should have.
  
  The user can then create objects where accessing that way gives the
  correct behavior.(by table directly, or metatable, doesnt matter)
  
* Namespace everything. TODO: urltamer still needs it.
  
* Users still may need to extend objects i create, and to do it
  with the fewest lines of code, that might imply needing knowledge
  about how the metatables work.

# License

Everything is GPLv3 unless *explicitly* indicated otherwise.
