--  Copyright (C) 27-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"
local history  = require "listview.cookies.cookies"

local paged_chrome = require("paged_chrome")

-- Make the chrome page.
local pages = listview.new_Chrome(history, "*listview/cookies")

-- NOTE: really maybe better via new metatable, but lazy.
pages.search.infofun = function(self)
   return self:config().infofun or {require "listview.cookies.infofun.show_1"}
end
pages.search.side_infofun = function(self)
   return self:config().side_infofun or {}
end

paged_chrome.chrome("listviewCookies", pages)

local config = (globals.listview or {}).cookies or {}

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   cookies.cmd_query = query  -- Bit "global-value-ie.
   w:new_tab("luakit://listviewCookies/search")
end

add_cmds({ cmd("listviewCookies", on_command) })
