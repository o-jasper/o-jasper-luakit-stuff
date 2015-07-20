--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"
local history  = require "listview.history.history"

local function mk_page(meta, name)
   return meta.new{name, history, "*listview/history"}
end

local pages = {
   default_name = "search",
   search = mk_page(listview.Search, "search"),
   aboutChrome = mk_page(listview.AboutChrome, "aboutChrome"),
}

local Public = {}

Public.listviewHistory = {
   chrome_name = "listviewHistory",
   pages = pages,
}

local config = (globals.listview or {}).history or {}

if config.take_history_chrome then  -- Take over the 'plain name'. (default:no)
   Public.history = {
      chrome_name = "history",
      pages = pages,
   }
end

if luakit then
   require "listview.history.binds"
end

return Public
