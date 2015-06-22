--  Copyright (C) 02=-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local config = globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

local lousy = require("lousy")

local c = require("o_jasper_common")

-- Apparently we dont need to know in order to satisfy the interface.
-- local pagedChrome = require "paged_chrome"

-- Making the objects that do the pages.
local Public = {
   Base = require "listview.Base",
   Search = require "listview.Search",
   AboutChrome = require "listview.AboutChrome"
}

local paged_chrome = require("paged_chrome")

-- Better not use.
function Public.new_Chrome(log, where, default_name)
   assert(log and where)
   return { default_name = default_name or "search",
            search = Public.Search.new{"search", log, where},
            aboutChrome = Public.AboutChrome.new{"aboutChrome", log, where},
   }
end

return Public
