--  Copyright (C) 27-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local ret

if not ret then
   local Cookies = require "listview.cookies.Cookies"

   local db = ((globals.listview or {}).cookies or {}).db
   if not db then
      if luakit then
         local pkg = require("cookies")
         pkg.init() -- (otherwise used `capi.luakit.idle_add(init)`)
      else
         local Sql = require "sql_help.luasql_port"
         db = Sql.new(globals.main_db_dir .. "cookies.db")
      end
   end

   ret = setmetatable({ db = db }, Cookies)
end

return ret
