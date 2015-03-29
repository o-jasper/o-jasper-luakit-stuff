--  Copyright (C) 27-02-2015 Jasper den Ouden.
--
--  This is free software: you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published
--  by the Free Software Foundation, either version 3 of the License, or
--  (at your option) any later version.

-- Chrome page of all logs. User may do subselection.

require "listview.chromable"
require "hist_n_bookmarks"

local config = globals.hist_n_bookmarks

-- TODO.. config the listview metas..
local function chrome_describe(default_name, log)
   return { default_name = default_name,
            search = templated_page(listview_chrome(log))
            add = setmetatable({}, metatable_of(listview_add_meta)),
            all = setmetatable({}, metatable_of(listview_all_meta)),
    }
end

-- Turned on defaultly.
if true or config.take_history then
   paged_chrome("_history", chrome_describe("history"), history)
end

if true or config.take_bookmarks then
   paged_chrome("_bookmarks", chrome_describe("bookmarks"), bookmarks)
end

-- paged_chrome("hist_n_bookmarks", chrome_describe("history", history))
   
