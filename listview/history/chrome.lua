--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview_chrome = require("listview").listview_chrome
require "listview.history"

local paged_chrome = require("paged_chrome")

local config = (globals.listview or {}).history or {}
config.page = config.page or {}

local function chrome_describe(default_name, log)
   assert(log)
   local page = listview_chrome(log, "search", "listview/history")
   page.limit_cnt = config.page.cnt or 20
   page.limit_step = config.page.step or page.step_cnt
   return { default_name = default_name,
            search = paged_chrome.templated_page(page),
   }
end

-- Make the chrome page.
local history_paged = chrome_describe("search", history)
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
