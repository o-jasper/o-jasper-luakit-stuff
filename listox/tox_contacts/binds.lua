-- Add bindings.
local lousy = require "lousy"
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   local v = w:new_tab("luakit://listoxContacts/search")
end

add_cmds({ cmd("listoxContacts", on_command) })
