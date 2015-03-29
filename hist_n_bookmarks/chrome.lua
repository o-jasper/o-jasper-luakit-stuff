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
   assert(log)
   return { default_name = default_name,
            search = templated_page(listview_chrome(log, "search")),
   }
end

-- Turned on defaultly.
if true or config.take_history then
   paged_chrome("fcknhistory", chrome_describe("search", history))
end

-- paged_chrome("hist_n_bookmarks", chrome_describe("history", history))
   
