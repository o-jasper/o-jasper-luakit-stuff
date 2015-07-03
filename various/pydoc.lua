local config = (globals.various or {}).pydoc or {}
local tmpdir = config.tmpdir or (globals.tmpdir or "/tmp/") .. "pydoc/"

local cmd = require("lousy").bind.cmd

add_cmds({
      cmd("pydoc", "Python documentation",
          function(w, query)
             luakit.spawn("mkdir -p " .. tmpdir)
             luakit.spawn(string.format([[bash -c "cd %s; pydoc -w %s"]], tmpdir, query),
                          function()
                             w:new_tab(string.format("file://%s%s.html", tmpdir, query))
             end)
      end),
})
