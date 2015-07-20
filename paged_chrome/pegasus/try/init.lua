local ipath = "/home/jasper/luakit/"

local libdir = "/home/jasper/iso/luakit/lib/"

local list = {"./?.lua","./usr/share/luajit-2.0.3/?.lua" }
local dirlist = {
   "/usr/local/share/lua/5.1/",
   "/usr/share/lua/5.1/",
   "./lib/",
   "/home/jasper/.lualibs/",
   "/home/jasper/oproj/browsing/luakit-stuff/o-jasper-luakit-stuff/",
   "/home/jasper/lib/lua-discount/",
   "/home/jasper/lib/luakit-plugins/",
   "/home/jasper/lib/luakit-more/",
   "/home/jasper/lib/luakit-sessman/",

   "/home/jasper/iso/luakit/luakit/lib/",

   -- Our stuff
   ipath .. "config/",
   ipath .. "lib/",
   "/etc/xdg/luakit/",
   "/usr/local/share/luakit/lib/",
}

for _, v in pairs(dirlist) do
   table.insert(list, v .. "?.lua")
   table.insert(list, v .. "?/init.lua")
   table.insert(list, v .. "?.so")
end

--table.insert(list, "/home/jasper/lib/lua-discount/")
package.path = table.concat(list, ";")

local reg = require "paged_chrome.reg"

globals = {
    listview = {
       history   = { take = { all=true } },
       bookmarks = { take = { all=true } },
    },
    main_db_path = "/home/jasper/iso/luakit/.local/share/luakit/history.db",
    main_db_dir = "/home/jasper/iso/luakit/.local/share/luakit/",
}

reg:register_table(require "paged_chrome.examples")

reg:register_table(require "listview.history.chrome")
reg:register_table(require "listview.bookmarks.chrome")
reg:register_table(require "listview.oldBookmarks.chrome")
reg:register_table(require "listview.cookies.chrome")

require("paged_chrome.pegasus")(reg)
