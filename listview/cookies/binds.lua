-- Add bindings.
local lousy = require "lousy"
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local cookies  = require "listview.cookies.cookies"

local function on_command(w, query)
   cookies.cmd_query = query  -- Bit "global-value-ie.
   w:new_tab("luakit://listviewCookies/search")
end

add_cmds({ cmd("listviewCookies", on_command) })
