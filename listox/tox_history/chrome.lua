--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"
local log  = require "listox.tox_history.tox_history"

local paged_chrome = require("paged_chrome")

local function chrome_describe(log)
   assert(log)
   return listview.new_Chrome(log, {"listox/tox_history", "listview"})
end

-- Make the chrome page.
paged_chrome.chrome("listoxHistory", chrome_describe(log))

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   local v = w:new_tab("luakit://listoxHistory/search")
end

add_cmds({ cmd("listoxHistory", on_command) })
