--  Copyright (C) 27-06-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"
local cookies  = require "listview.cookies.cookies"

local function mk_page(meta, name)
   return meta.new{name, cookies, "*listview/cookies"}
end

-- Make the chrome page.
local pages = {
   default_name = "search",
   search = mk_page(listview.Search, "search"),
   aboutChrome = mk_page(listview.AboutChrome, "aboutChrome"),
}

-- NOTE: really maybe (tiny bit)better via new metatable, but lazy.
pages.search.infofun = function(self)
   return self:config().infofun or {require "listview.cookies.infofun.show_1"}
end
pages.search.side_infofun = function(self)
   return self:config().side_infofun or {}
end

local Public = {}
Public.listviewCookies = {
   chrome_name = "listviewCookies",
   pages = pages,
}

local config = (globals.listview or {}).cookies or {}

if luakit then require "listview.cookies.binds" end

return Public
