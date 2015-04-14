# Bunch of [luakit](http://mason-larobina.github.io/luakit/) things

* [search_login](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/search_login#log-in-using-pass), which uses `pass` and searching the html to login.
* [urltamer](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/urltamer#taming-the-urls-that-are-accessed), running code based on `uri` being accessed,
  blocking/redirecting/managing view behavior based on them.
* A [nicer history searcher](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/hist_n_bookmarks/).
* .. based on [listview](https://github.com/o-jasper/o-jasper-luakit-stuff/tree/master/listview#list-view-lib--messages-lib)
  searching SQL, however, might end up just doing so over 
  logs, messages, bookmarks, history. (limited extent)

Note that although it is called `o-jasper-luakit-stuff`, i dont mean that it is
just my project. Just not-clogging the namespace, and getting all the damn
things in one repo.

## Principles
In order to keep things easy for others to use/extend too, need more
principles.

* For extension, never require knowledge about the metatables i am using.

  Basically, whenever the "user"(still a programmer) provides an object,
  the reference will just tell him what members that object should have.
  
  The user can then create objects where accessing that way gives the
  correct behavior.(by table directly, or metatable, doesnt matter)
  
* *TODO*, there is basically no namespacing at the moment, which is
  *not* nice.
  
* *TODO* similar for how objects are extended.. Needs to be more robust
  and clear.
  
# License

Everything is GPLv3 unless *explicitly* indicated otherwise.
