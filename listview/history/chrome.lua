--  Copyright (C) 27-04-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require("listview")
local history  = require "listview.history.history"

local paged_chrome = require("paged_chrome")

local config = (globals.listview or {}).history or {}
config.page = config.page or {}

local function chrome_describe(log)
   assert(log)
   local pages = listview.new_Chrome(log, "listview/history")
   pages.search.limit_cnt = config.page.cnt or 20
   pages.search.limit_step = config.page.step or pages.search.step_cnt
   return pages
end

-- Make the chrome page.
local history_paged = chrome_describe(history)
paged_chrome.paged_chrome("listviewHistory", history_paged)

if config.take_history_chrome then  -- Take over the 'plain name'. (default:no)
   paged_chrome.paged_chrome("history", history_paged)
end

-- Add bindings.
local cmd = lousy.bind.cmd

local function on_command(w, query)
   history.latest_query = query
   local v = w:new_tab("luakit://listviewHistory/search")
   -- if query then  -- This would be without the nasty "global value" thing.
   --  v:eval_js(string.format("ge('search').value = %q; search();", query))
   -- end
end

add_cmds({ cmd("listviewHistory", on_command) })

if config.take_history_cmd then add_cmds({ cmd("history", on_command) }) end
