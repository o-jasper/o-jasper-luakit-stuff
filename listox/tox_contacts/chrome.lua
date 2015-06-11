--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"
local log  = require "listox.tox_contacts.tox_contacts"

local paged_chrome = require("paged_chrome")

local function chrome_describe(log)
   assert(log)
   return listview.new_Chrome(log, {"listox/tox_contacts", "listview"})
end

-- Make the chrome page.
paged_chrome.paged_chrome("listoxContacts", chrome_describe(log))

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   local v = w:new_tab("luakit://listoxContacts/search")
end

add_cmds({ cmd("listoxContacts", on_command) })
