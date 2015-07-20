local config = (globals.listview or {}).history or {}

-- Add bindings.
local lousy = require "lousy"
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   history.cmd_query = query  -- Bit "global-value-ie.
   w:new_tab("luakit://listviewHistory/search")
end

add_cmds({ cmd("listviewHistory", on_command) })

local take = config.take or {}
if take.all then take = setmetatable({}, {__index=function(...) return true end}) end

local function firstarg(fun) return function(x) return fun(x) end end

if take.history_cmd then add_cmds({ cmd("history", on_command) }) end
if take.binds then add_binds("normal", { buf("^gh", firstarg(on_command)) }) end
