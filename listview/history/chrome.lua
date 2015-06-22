--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"
local history  = require "listview.history.history"

local paged_chrome = require("paged_chrome")

-- Make the chrome page.
local history_paged = listview.new_Chrome(history, "*listview/history")
paged_chrome.chrome("listviewHistory", history_paged)

local config = (globals.listview or {}).history or {}

if config.take_history_chrome then  -- Take over the 'plain name'. (default:no)
   paged_chrome.chrome("history", history_paged)
end

-- Add bindings.
local cmd,buf,key = lousy.bind.cmd, lousy.bind.buf, lousy.bind.key

local function on_command(w, query)
   history.cmd_query = query  -- Bit "global-value-ie.
   local v = w:new_tab("luakit://listviewHistory/search")
end

add_cmds({ cmd("listviewHistory", on_command) })

local take = config.take or {}
if take.all then take = setmetatable({}, {__index=function(...) return true end}) end

local function firstarg(fun) return function(x) return fun(x) end end

if take.history_cmd then add_cmds({ cmd("history", on_command) }) end
if take.binds then add_binds("normal", { buf("^gh", firstarg(on_command)) }) end

