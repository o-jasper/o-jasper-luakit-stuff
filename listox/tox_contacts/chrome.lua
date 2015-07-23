--  Copyright (C) 10-05-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

local listview = require "listview"

if luakit then
   require "listox.tox_contacts.binds"
end

local tox_contacts  = require "listox.tox_contacts.tox_contacts"

local function mk_page(meta, name)
   return meta.new{name, tox_contacts, "*listview/history"}
end

local pages = {
   default_name = "search",
   search = mk_page(listview.Search, "search"),
   aboutChrome = mk_page(listview.AboutChrome, "aboutChrome"),
}

return {
   listoxContacts = {
      chrome_name = "listoxContacts",
      pages = pages,
   }
}
