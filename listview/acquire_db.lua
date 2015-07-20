if luakit then
   local histpkg = require("history")
   histpkg.init() -- History package uses `capi.luakit.idle_add(init)`
   return histpkg.db
else  -- Aint got no luakit.. gotta get the sql lib and open it ourselves,
   local Sql = require "sql_help.luasql_port"
   return Sql.new(globals.main_db_path)
end
