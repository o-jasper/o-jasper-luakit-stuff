--  Copyright (C) 02=-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- TODO awfully little done here... can we make it do nothing?

local config = globals.listview or {}
config.addsearch = config.addsearch or { default = "" }

-- Making the objects that do the pages.
local Public = {
   Base = require "listview.Base",
   Search = require "listview.Search",
   AboutChrome = require "listview.AboutChrome"
}

return Public
