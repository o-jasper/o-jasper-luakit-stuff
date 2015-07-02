
local config = (globals.various or {}).man or {}
local tmpdir = config.tmpdir or (globals.tmpdir or "/tmp/") .. "man/"

luakit.spawn("mkdir -p " .. tmpdir)

local cmd = require("lousy").bind.cmd

add_cmds({
             cmd("man", "Open manual page",
                 function(w, query)
                    local to_file = tmpdir .. query .. ".html"
                    local cmd = [[man --html="cat %s > ]] .. to_file .. "\" " .. query
                    luakit.spawn(cmd,  
                                 function() w:new_tab("file://" .. to_file) end)
             end)
})
